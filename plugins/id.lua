local function user_print_name(user)
  if user.print_name then
    return user.print_name
  end
  local text = ''
  if user.first_name then
    text = user.last_name..' '
  end
  if user.lastname then
    text = text..user.last_name
  end
  return text
end

local function returnids(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local chat_id = "chat#id"..result.id
  local chatname = result.print_name

  local text = 'IDs for chat '..chatname
  ..' ('..chat_id..')\n'
  ..'There are '..result.members_num..' members'
  ..'\n---------\n'
  for k,v in pairs(result.members) do
    text = text .. v.print_name .. " (user#id" .. v.id .. ")\n"
  end
  send_large_msg(receiver, text)
end

local function run(msg, matches)
  local receiver = get_receiver(msg)
  if matches[1] == "!id" then
    local text = user_print_name(msg.from) .. ' (user#id' .. msg.from.id .. ')'
    if is_chat_msg(msg) then
      text = text .. "\nYou are in group " .. user_print_name(msg.to) .. " (chat#id" .. msg.to.id  .. ")"
    end
    return text
  elseif matches[1] == "chat" then
    -- !ids? (chat) (%d+)
    if matches[2] and is_sudo(msg) then
      local chat = 'chat#id'..matches[2]
      chat_info(chat, returnids, {receiver=receiver})
    else
      if not is_chat_msg(msg) then
        return "You are not in a group."
      end
      local chat = get_receiver(msg)
      chat_info(chat, returnids, {receiver=receiver})
    end
  elseif matches[1] == "member" and matches[2] == "@" then
    local nick = matches[3]
    local chat = get_receiver(msg)
    if not is_chat_msg(msg) then
      return "You are not in a group."
    end
    chat_info(chat, function (extra, success, result)
      local receiver = extra.receiver
      local nick = extra.nick
      print("Searching: "..nick)
      local found
      for k,user in pairs(result.members) do
        if user.username == nick then
          found = user
        end
      end
      if not found then
        send_msg(receiver, "User not found on this chat.", ok_cb, false)
      else
        local text = "ID: "..found.id
        send_msg(receiver, text, ok_cb, false)
      end
    end, {receiver=chat, nick=nick})
  end
end

return {
  description = "Know your id or the id of a chat members.",
  usage = {
    "!id: Return your ID and the chat id if you are in one.",
    "!ids chat: Return the IDs of the current chat members.",
    "!ids chat <chat_id>: Return the IDs of the <chat_id> members.",
    "!id member @<user_name>: Return the member @<user_name> ID from the current chat"
  },
  patterns = {
    "^!id$",
    "^!ids? (chat) (%d+)$",
    "^!ids? (chat)$",
    "^!id (member) (@)(.+)"
  },
  run = run
}
