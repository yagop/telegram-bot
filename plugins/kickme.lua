local function kick_user(user_id, chat_id)
  local chat = 'chat#id'..chat_id
  local user = 'user#id'..user_id
  chat_del_user(chat, user, function (data, success, result)
    if success ~= 1 then
      send_msg(data.chat, 'Error while kicking user', ok_cb, nil)
    end
  end, {chat=chat, user=user})
end

local function run (msg, matches)
  local user = msg.from.id
  local chat = msg.to.id

  if msg.to.type ~= 'chat' then
    return "Not a chat group!"
  elseif user == our_id then
    --[[ A robot must protect its own existence as long as such protection does
    not conflict with the First or Second Laws. ]]--
    return "I won't kick myself!"
  elseif is_sudo(msg) then
    return "I won't kick an admin!"
  else
    kick_user(user, chat)
  end
end

return {
  description = "Bot kicks user",
  usage = {
    "!kickme"
  },
  patterns = {
    "^!kickme$"
  },
  run = run
}
