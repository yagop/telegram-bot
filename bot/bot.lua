http = require("socket.http")
https = require("ssl.https")
URL = require("socket.url")
json = (loadfile "./libs/JSON.lua")()
serpent = (loadfile "./libs/serpent.lua")()
require("./bot/utils")

VERSION = '0.9.3'

function on_msg_receive (msg)
  vardump(msg)

  if msg_valid(msg) == false then
    return
  end

  do_action(msg)
end

function ok_cb(extra, success, result)
end

function on_binlog_replay_end ()
  started = 1
  -- Uncomment the line to enable cron plugins.
  postpone (cron_plugins, false, 60*5.0)
  -- See plugins/ping.lua as an example for cron

  _config = load_config()

  -- load plugins
  plugins = {}
  load_plugins()
end

function msg_valid(msg)
  -- Dont process outgoing messages
  if msg.out then
    print("Not valid, msg from us")
    return false
  end
  if msg.date < now then
    print("Not valid, old msg")
    return false
  end
  if msg.unread == 0 then
    print("Not valid, readed")
    return false
  end
end

function do_lex(msg, text)
  -- Plugins which implements lex.
  for name, desc in pairs(plugins) do
    if (desc.lex ~= nil) then
      result = desc.lex(msg, text)
      if (result ~= nil) then
        print ("Mutating to " .. result)
        text = result
      end
    end
  end
  return text
end

-- Where magic happens
function do_action(msg)
  local receiver = get_receiver(msg)
  local text = msg.text

  if text == nil then
    -- Not a text message, make text the same as what tg shows so
    -- we can match on it. Maybe a plugin activated my media type.
    if msg.media ~= nil then
      text = '['..msg.media.type..']'
    end
  end

  -- We can't do anything
  if msg.text == nil then return false end

  msg.text = do_lex(msg, text)

  for name, desc in pairs(plugins) do
    -- print("Trying module", name)
    for k, pattern in pairs(desc.patterns) do
      -- print("Trying", text, "against", pattern)
      matches = { string.match(text, pattern) }
      if matches[1] then
        mark_read(get_receiver(msg), ok_cb, false)
        print("  matches", pattern)
        if desc.run ~= nil then
          -- If plugin is for privileged user
          if desc.privileged and not is_sudo(msg) then
            local text = 'This plugin requires privileged user'
            send_msg(receiver, text, ok_cb, false)
          else 
            result = desc.run(msg, matches)
            -- print("  sending", result)
            if (result) then
              result = do_lex(msg, result)
              _send_msg(receiver, result)
            end
          end
        end
      end
    end
  end
end

-- If text is longer than 4096 chars, send multiple msg.
-- https://core.telegram.org/method/messages.sendMessage
function _send_msg( destination, text)
  local msg_text_max = 4096
  local len = string.len(text)
  local iterations = math.ceil(len / msg_text_max)

  for i = 1, iterations, 1 do
    local inital_c = i * msg_text_max - msg_text_max
    local final_c = i * msg_text_max
    -- dont worry about if text length < msg_text_max
    local text_msg = string.sub(text,inital_c,final_c)
    send_msg(destination, text_msg, ok_cb, false)
  end
end

-- Save the content of _config to config.lua
function save_config( )
  serialize_to_file(_config, './data/config.lua')
  print ('saved config into ./data/config.lua')
end


function load_config( )
  local f = io.open('./data/config.lua', "r")
  -- If config.lua doesnt exists
  if not f then
    print ("Created new config file: data/config.lua")
    create_config()
  else
    f:close()
  end
  local config = loadfile ("./data/config.lua")()
  for v,user in pairs(config.sudo_users) do
    print("Allowed user: " .. user)
  end
  return config
end

-- Create a basic config.json file and saves it.
function create_config( )
  -- A simple config with basic plugins and ourserves as priviled user
  config = {
    enabled_plugins = {
      "9gag",
      "eur",
      "echo",
      "btc",
      "get",
      "giphy",
      "google",
      "gps",
      "help",
      "images",
      "img_google",
      "location",
      "media",
      "plugins",
      "set",
      "stats",
      "time",
      "version",
      "weather",
      "xkcd",
      "youtube" },
    sudo_users = {our_id}  
  }
  serialize_to_file(config, './data/config.lua')
  print ('saved config into ./data/config.lua')
end

function on_our_id (id)
  our_id = id
end

function on_user_update (user, what)
  --vardump (user)
end

function on_chat_update (chat, what)
  --vardump (chat)
end

function on_secret_chat_update (schat, what)
  --vardump (schat)
end

function on_get_difference_end ()
end

-- Enable plugins in config.json
function load_plugins()
  for k, v in pairs(_config.enabled_plugins) do
    print("Loading plugin", v)
    t = loadfile("plugins/"..v..'.lua')()
    table.insert(plugins, t)
  end
end

-- Cron all the enabled plugins
function cron_plugins()

  for name, desc in pairs(plugins) do
    if desc.cron ~= nil then
      print(desc.description)
      desc.cron()
    end
  end

  -- Called again in 5 mins
  postpone (cron_plugins, false, 5*60.0)
end

-- Start and load values
our_id = 0
now = os.time()
math.randomseed(now)