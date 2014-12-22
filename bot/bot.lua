http = require("socket.http")
https = require("ssl.https")
URL = require("socket.url")
json = (loadfile "./bot/JSON.lua")()
require("./bot/utils")

VERSION = 'v0.7.7'

function on_msg_receive (msg)
  vardump(msg)

  if msg_valid(msg) == false then
    return
  end

  update_user_stats(msg)
  do_action(msg)

  mark_read(get_receiver(msg), ok_cb, false)
end

function ok_cb(extra, success, result)
end

-- Callback to remove tmp files
function rmtmp_cb(file_path, success, result)
   os.remove(file_path)
end

function msg_valid(msg)
  -- if msg.from.id == our_id then
  --   return true
  -- end
  if msg.out then
    return false
  end
  if msg.date < now then
    return false
  end
  if msg.unread == 0 then
    return false
  end
end

-- Where magic happens
function do_action(msg)
  local receiver = get_receiver(msg)
  local text = msg.text
  if msg.text == nil then
     -- Not a text message, make text the same as what tg shows so
     -- we can match on it. The plugin is resposible for handling
     text = '['..msg.media.type..']'
  end
  -- print("Received msg", text)
  for name, desc in pairs(plugins) do
    -- print("Trying module", name)
    for k, pattern in pairs(desc.patterns) do
      -- print("Trying", text, "against", pattern)
      matches = { string.match(text, pattern) }
      if matches[1] then
        print("  matches",pattern)
        if desc.run ~= nil then
          result = desc.run(msg, matches)
          print("  sending", result)
          if (result) then
            _send_msg(receiver, result)
            return
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


function load_config()
   local f = assert(io.open('./bot/config.json', "r"))
   local c = f:read "*a"
   local config = json:decode(c)
   if config.sh_enabled then 
      print ("!sh command is enabled")
      for v,user in pairs(config.sudo_users) do
         print("Allowed user: " .. user)
      end
   end
   f:close()
   return config
end

function update_user_stats(msg)
   -- Save user to _users table
  local from_id = tostring(msg.from.id)
  local to_id = tostring(msg.to.id)
  local user_name = get_name(msg)
  -- If last name is nil dont save last_name.
  local user_last_name = msg.from.last_name
  local user_print_name = msg.from.print_name
  if _users[to_id] == nil then
    _users[to_id] = {}
  end
  if _users[to_id][from_id] == nil then
    _users[to_id][from_id] = {
      name = user_name,
      last_name = user_last_name,
      print_name = user_print_name,
      msg_num = 1
    }
  else
    local actual_num = _users[to_id][from_id].msg_num
    _users[to_id][from_id].msg_num = actual_num + 1
    -- And update last_name
    _users[to_id][from_id].last_name = user_last_name
  end
end

function load_user_stats()
  local f = io.open('res/users.json', "r+")
  -- If file doesn't exists
  if f == nil then
    f = io.open('res/users.json', "w+")
    f:write("{}") -- Write empty table
    f:close()
    return {}
  else
    local c = f:read "*a"
    f:close()
    return json:decode(c)
  end
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

function on_binlog_replay_end ()
  started = 1
  -- Uncomment the line to enable cron plugins.
  -- postpone (cron_plugins, false, 5.0)
  -- See plugins/ping.lua as an example for cron
end

-- load all plugins in the plugins/ directory
function load_plugins()
  for k, v in pairs(scandir("plugins")) do
    -- Load only lua files
    if (v:match(".lua$")) then
        print("Loading plugin", v)
        t = loadfile("plugins/" .. v)()
        table.insert(plugins, t)
    end 
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

config = load_config()
_users = load_user_stats()

-- load plugins
plugins = {}
load_plugins()