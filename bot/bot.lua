require("./bot/utils")

VERSION = '0.10.1'

-- This function is called when tg receive a msg
function on_msg_receive (msg)
  -- vardump(msg)
  if msg_valid(msg) then
    msg = pre_process_msg(msg)
    match_plugins(msg)
  end
end

function ok_cb(extra, success, result)
end

function on_binlog_replay_end()
  started = 1
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
    if msg.text:sub(1, 1) == "%" then
      msg.text = msg.text:sub(2, msg.text:len())
      return true
    else 
      print("Not valid, msg from us")
      return false
    end
  end
  if msg.date < now then
    print("Not valid, old msg")
    return false
  end
  if msg.unread == 0 then
    print("Not valid, readed")
    return false
  end
  return true
end


function do_lex(msg)
  -- Plugins which implements lex.
  for name, plugin in pairs(plugins) do
    if plugin.lex ~= nil then
      msg = plugin.lex(msg)
    end
  end

  return msg
end

-- Go over enabled plugins patterns.
function match_plugins(msg)
  for name, plugin in pairs(plugins) do
    match_plugin(plugin, msg)
  end
end

function match_plugin(plugin, msg)
  local receiver = get_receiver(msg)

  -- Go over patterns. If one matches is enought.
  for k, pattern in pairs(plugin.patterns) do
    -- print(msg.text, pattern)
    matches = { string.match(msg.text, pattern) }
    if matches[1] then
      mark_read(receiver, ok_cb, false)
      print("  matches", pattern)
      -- Function exists
      if plugin.run ~= nil then
        -- If plugin is for privileged users only
        if not user_allowed(plugin, msg) then
          local text = 'This plugin requires privileged user'
          send_msg(receiver, text, ok_cb, false)
        else
          -- Send the returned text by run function.
          result = plugin.run(msg, matches)
          if result ~= nil then
            _send_msg(receiver, result)
          end
        end
      end
      -- One matches
      return
    end
  end
end

-- Check if user can use the plugin
function user_allowed(plugin, msg)
  if plugin.privileged and not is_sudo(msg) then
    return false
  end
  return true
end

--Apply lex and other text.
function pre_process_msg(msg)

  if msg.text == nil then
    -- Not a text message, make text the same as what tg shows so
    -- we can match on it. Maybe a plugin activated my media type.
    if msg.media ~= nil then
      msg.text = '['..msg.media.type..']'
    end
  end

  msg = do_lex(msg)

  return msg
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

-- Returns the config from config.lua file.
-- If file doesnt exists, create it.
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
    local t = loadfile("plugins/"..v..'.lua')()
    plugins[v] = t
  end
end

-- Call and postpone execution for cron plugins
function cron_plugins()

  for name, plugin in pairs(plugins) do
    -- Only plugins with cron function
    if plugin.cron ~= nil then
      plugin.cron()
    end
  end

  -- Called again in 5 mins
  postpone (cron_plugins, false, 5*60.0)
end

-- Start and load values
our_id = 0
now = os.time()
math.randomseed(now)
