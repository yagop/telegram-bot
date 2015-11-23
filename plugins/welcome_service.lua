do

local function welcome_message(msg, new_member)

  local data = load_data(_config.moderation.data)
  local welcome_stat = data[tostring(msg.to.id)]['settings']['welcome']

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
    if welcome_stat == 'group' then
      receiver = get_receiver(msg)
    elseif welcome_stat == 'private' then
      receiver = 'user#id'..msg.from.id
    end
    send_large_msg(receiver, welcomes..about..rules.."\n", ok_cb, false)
  end
end

local function run(msg, matches)

  local data = load_data(_config.moderation.data)
  local welcome_stat = data[tostring(msg.to.id)]['settings']['welcome']

  if matches[1] == 'welcome' then
    if matches[2] == 'group' then
      if welcome_stat ~= 'group' then
        data[tostring(msg.to.id)]['settings']['welcome'] = 'group'
        save_data(_config.moderation.data, data)
      end
      return 'Welcome service already enabled.\nWelcome message will shown in group.'
    end
    if matches[2] == 'private' then
      if welcome_stat ~= 'pm' then
        data[tostring(msg.to.id)]['settings']['welcome'] = 'private'
        save_data(_config.moderation.data, data)
      end
      return 'Welcome service already enabled.\nWelcome message will send as private message to new member.'
    end
    if matches[2] == 'disable' then
      if welcome_stat == 'no' then
        return 'Welcome service is not enabled.'
      else
        data[tostring(msg.to.id)]['settings']['welcome'] = 'no'
        save_data(_config.moderation.data, data)
        return 'Welcome service has been disabled.'
      end
    end
  end

  if welcome_stat ~= 'no' and msg.service then
    if matches[1] == "chat_add_user" then
      if not msg.action.user.username then
        new_member = string.gsub(msg.action.user.print_name, '_', ' ')
      else
        new_member = '@'..msg.action.user.username
      end
      welcome_message(msg, new_member)
    elseif matches[1] == "chat_add_user_link" then
      if not msg.from.username then
        new_member = string.gsub(msg.from.print_name, '_', ' ')
      else
        new_member = '@'..msg.from.username
      end
      welcome_message(msg, new_member)
    elseif matches[1] == "chat_del_user" then
      local bye_name = msg.action.user.first_name
      return 'Bye '..bye_name..'!'
    end
  end

end

return {
  description = 'Sends a custom message when a user enters or leave a chat.',
  usage = {
    '!welcome group : Welcome message will shows in group.',
    '!welcome pm : Welcome message will send to new member via PM.',
    '!welcome disable : Disable welcome message.'
  },
  patterns = {
    "^!!tgservice (.+)$",
    "^!(welcome) (.*)$"
  },
  run = run
}

end
