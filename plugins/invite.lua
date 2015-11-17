-- Invite other user to the chat group.
-- Use !invite @username to invite a user by @username
-- Use !invite ********* (where ********* is id_number) to invite a user by id_number
-- Use !invite Type print_name Here to invite a user by print_name

do

-- Think it's kind of useless. Just to suppress '*** lua: attempt to call a nil value'
local function callback(extra, success, result)
  vardump(success)
  vardump(result)
  vardump(extra)
  if success == 0 then
    return send_large_msg(chat, "Can't invite user to this group.")
  else
    return extra.text
  end
end

local function res_user_callback(extra, success, result)
  local user = 'user#id'..result.id
  local chat = extra.chat
  if success == 0 then
    return send_large_msg(chat, "Can't invite user to this group.")
  end
  chat_add_user(chat, user, callback, false)
  return extra.text
end

local function run(msg, matches)
  local user = matches[1]
  local chat = 'chat#id'..msg.to.id
  local text = "Add: "..user.." to "..chat
  if msg.to.type == 'chat' then
    if string.match(user, '^%d+$') then
      user = 'user#id'..user
      chat_add_user(chat, user, callback, {chat=chat, text=text})
    elseif string.match(user, '^@.+$') then
      username = string.gsub(user, '@', '')
      msgr = res_user(username, res_user_callback, {chat=chat, text=text})
    else
      user = string.gsub(user, ' ', '_')
      chat_add_user(chat, user, callback, {chat=chat, text=text})
    end
  else 
    return 'This isnt a chat group!'
  end
end

return {
  description = "Invite other user to the chat group.",
  usage = {
    -- need space in front of this, so bot won't consider it as a command
    ' !invite [id|user_name|name]'
  },
  patterns = {
    "^!invite (.*)$",
    "^!invite (%d+)$"
  }, 
  run = run 
}

end
