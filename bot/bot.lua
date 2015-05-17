package.path = package.path .. ';.luarocks/share/lua/5.2/?.lua'
  ..';.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath .. ';.luarocks/lib/lua/5.2/?.so'

require("./bot/utils")

VERSION = '0.12.2'

-- This function is called when tg receive a msg
function on_msg_receive (msg)
  return BOT.on_msg_receive(msg)
end

function ok_cb(extra, success, result)
end

function on_binlog_replay_end()
  reload_bot()
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

function reload_bot() 
  BOT = nil
  print("Loading bot module")
  BOT = loadfile("./bot/botmodule.lua")()
  return BOT.start()
end

-- Start and load values
BOT = nil
our_id = 0
started = false
