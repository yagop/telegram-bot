do

local function description_rules(msg, new_member)
  local data = load_data(_config.moderation.data)
  if data[tostring(msg.to.id)] then
    local about = ''
    local rules = ''
    if data[tostring(msg.to.id)]['description'] then
      about = data[tostring(msg.to.id)]['description']
      about = "\nDescription :\n"..about.."\n"
    end
    if data[tostring(msg.to.id)]['rules'] then
      rules = data[tostring(msg.to.id)]['rules']
      rules = "\nRules :\n"..rules.."\n"
    end
    local welcomes = "Welcome "..new_member..".\nYou are in group '"..string.gsub(msg.to.print_name, "_", " ").."'\n"
    send_large_msg(get_receiver(msg), welcomes..about..rules.."\n", ok_cb, false)
  end
end

local function run(msg, matches)
  if not msg.service then
    return 'Are you trying to troll me?'
  end
  if matches[1] == "chat_add_user" then
    if not msg.action.user.username then
      new_member = string.gsub(msg.action.user.print_name, '_', ' ')
    else
      new_member = '@'..msg.action.user.username
    end
    description_rules(msg, new_member)
  elseif matches[1] == "chat_add_user_link" then
    if not msg.from.username then
      new_member = string.gsub(msg.from.print_name, '_', ' ')
    else
      new_member = '@'..msg.from.username
    end
    description_rules(msg, new_member)
  elseif matches[1] == "chat_del_user" then
    local bye_name = msg.action.user.first_name
    return 'Bye '..bye_name..'!'
  end
end

return {
  description = 'Service plugin that sends a custom message when a user enters a chat.',
  usage = 'Welcoming new member.',
  patterns = {
    "^!!tgservice (chat_add_user)$",
    "^!!tgservice (chat_add_user_link)$",
    "^!!tgservice (chat_del_user)$"
  },
  run = run
}

end
