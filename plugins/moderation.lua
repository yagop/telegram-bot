do

local function check_member(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local data = cb_extra.data
  local msg = cb_extra.msg
  for k,v in pairs(result.members) do
    local member_id = v.id
    if member_id ~= our_id then
      local username = v.username
      data[tostring(msg.to.id)] = {
        moderators = {[tostring(member_id)] = username},
        settings = {
          set_name = string.gsub(msg.to.print_name, '_', ' '),
          lock_bots = 'no',
          lock_name = 'no',
          lock_photo = 'no',
          lock_member = 'no',
          anti_flood = 'no',
          welcome = 'no'
          }
       }
      save_data(_config.moderation.data, data)
      return send_large_msg(receiver, 'You have been promoted as moderator for this group.')
    end
  end
end

local function automodadd(msg)
  local data = load_data(_config.moderation.data)
  if msg.action.type == 'chat_created' then
    receiver = get_receiver(msg)
    chat_info(receiver, check_member,{receiver=receiver, data=data, msg=msg})
  else
    if data[tostring(msg.to.id)] then
      return 'Group is already added.'
    end
    if msg.from.username then
      username = msg.from.username
    else
      username = msg.from.print_name
    end
    -- create data array in moderation.json
    data[tostring(msg.to.id)] = {
      moderators ={[tostring(msg.from.id)] = username},
      settings = {
        set_name = string.gsub(msg.to.print_name, '_', ' '),
        lock_bots = 'no',
        lock_name = 'no',
        lock_photo = 'no',
        lock_member = 'no',
        anti_flood = 'no',
        welcome = 'no'
        }
      }
    save_data(_config.moderation.data, data)
    return 'Group has been added, and @'..username..' has been promoted as moderator for this group.'
  end
end

local function promote(receiver, member_username, member_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'chat#id', '')
  if not data[group] then
    return send_large_msg(receiver, 'Group is not added.')
  end
  if data[group]['moderators'][tostring(member_id)] then
    return send_large_msg(receiver, member_username..' is already a moderator.')
  end
  data[group]['moderators'][tostring(member_id)] = member_username
  save_data(_config.moderation.data, data)
  return send_large_msg(receiver, member_username..' has been promoted as moderator for this group.')
end

local function demote(receiver, member_username, member_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'chat#id', '')
  if not data[group] then
    return send_large_msg(receiver, 'Group is not added.')
  end
  if not data[group]['moderators'][tostring(member_id)] then
    return send_large_msg(receiver, member_username..' is not a moderator.')
  end
  data[group]['moderators'][tostring(member_id)] = nil
  save_data(_config.moderation.data, data)
  return send_large_msg(receiver, member_username..' has been demoted from moderator of this group.')
end

local function admin_promote(receiver, member_username, member_id)
  local data = load_data(_config.moderation.data)
  if not data['admins'] then
    data['admins'] = {}
    save_data(_config.moderation.data, data)
  end

  if data['admins'][tostring(member_id)] then
   return send_large_msg(receiver, member_username..' is already as admin.')
  end

  data['admins'][tostring(member_id)] = member_username
  save_data(_config.moderation.data, data)
  return send_large_msg(receiver, member_username..' has been promoted as admin.')
end

local function admin_demote(receiver, member_username, member_id)
  local data = load_data(_config.moderation.data)
  if not data['admins'] then
    data['admins'] = {}
    save_data(_config.moderation.data, data)
  end

  if not data['admins'][tostring(member_id)] then
    return send_large_msg(receiver, member_username..' is not an admin.')
  end

  data['admins'][tostring(member_id)] = nil
  save_data(_config.moderation.data, data)

  return send_large_msg(receiver, 'Admin '..member_username..' has been demoted.')
end

local function username_id(extra, success, result)
  local mod_cmd = extra.mod_cmd
  local receiver = extra.receiver
  local member = extra.username
  for k,v in pairs(result.members) do
    vusername = v.username
    if vusername == member then
      member_username = '@'..member
      member_id = v.id
      if mod_cmd == 'promote' then
        return promote(receiver, member_username, member_id)
      elseif mod_cmd == 'demote' then
        return demote(receiver, member_username, member_id)
      elseif mod_cmd == 'adminprom' then
        return admin_promote(receiver, member_username, member_id)
      elseif mod_cmd == 'admindem' then
        return admin_demote(receiver, member_username, member_id)
      end
    end
  end
  send_large_msg(receiver, 'No user '..member..' in this group.')
end

local function action_by_id(extra, success, result)
  if success == 1 then
    local matches = extra.matches
    local receiver = 'chat#id'..result.id
    local member = matches[2]
    for k,v in pairs(result.members) do
      vuserid = tostring(v.id)
      if matches[2] == vuserid then
        print(vuserid, member, v.id)
        local full_name = (v.first_name or '')..' '..(v.last_name or '')
        local member_username = 'user#id'..member
        local member_id = vuserid
        if matches[1] == 'promote' then
          return promote(receiver, member_username, member_id)
        elseif matches[1] == 'demote' then
          return demote(receiver, member_username, member_id)
        elseif matches[1] == 'adminprom' then
          return admin_promote(receiver, member_username, member_id)
        elseif matches[1] == 'admindem' then
          return admin_demote(receiver, member_username, member_id)
        end
      end
    end
    send_large_msg(receiver, 'No user user#id'..member..' in this group.')
  end
end

local function action_by_reply(extra, success, result)
  local msg = result
  local receiver = get_receiver(msg)
  local full_name = (msg.from.first_name or '')..' '..(msg.from.last_name or '')
  local member_username = (msg.from.username or full_name)
  local member_id = msg.from.id
  if msg.to.type == 'chat' and not is_sudo(msg) then
    if extra.msg.text == '!promote' then
      return promote(receiver, member_username, member_id)
    elseif extra.msg.text == '!demote' then
      return demote(receiver, member_username, member_id)
    elseif extra.msg.text == '!adminprom' then
      return admin_promote(receiver, member_username, member_id)
    elseif extra.msg.text == '!admindem' then
      return admin_demote(receiver, member_username, member_id)
    end
  else
    return 'Use This in Your Groups.'
  end
end

local function modlist(msg)
  local data = load_data(_config.moderation.data)
  if not data[tostring(msg.to.id)] then
    return 'Group is not added.'
  end
  -- determine if table is empty
  if next(data[tostring(msg.to.id)]['moderators']) == nil then --fix way
    return 'No moderator in this group.'
  end
  local message = 'List of moderators for ' .. string.gsub(msg.to.print_name, '_', ' ') .. ':\n'
  for k,v in pairs(data[tostring(msg.to.id)]['moderators']) do
    message = message .. '- '..v..' [' ..k.. '] \n'
  end

  return message
end

local function admin_list(msg)
  local data = load_data(_config.moderation.data)
  if not data['admins'] then
    data['admins'] = {}
    save_data(_config.moderation.data, data)
  end
  if next(data['admins']) == nil then --fix way
    return 'No admin available.'
  end
  local message = 'List for Bot admins:\n'
  for k,v in pairs(data['admins']) do
    message = message .. '- ' .. v ..' ['..k..'] \n'
  end
  return message
end

function run(msg, matches)

  local mod_cmd = matches[1]
  local receiver = get_receiver(msg)

  if not is_chat_msg(msg) then
    return "Only works on group"
  end

  if matches[1] == 'promote' then
    if not is_mod(msg) then
      return "Only moderator can promote."
    end
    if msg.reply_id then
      msgr = get_message(msg.reply_id, action_by_reply, {msg=msg})
    end
    if matches[2] then
      if string.match(matches[2], '^%d+$') then
        local user_id = 'user_'..matches[2]
        chat_info(receiver, action_by_id, {msg=msg, matches=matches})
      elseif string.match(matches[2], '^@.+$') then
        local username = string.gsub(matches[2], '@', '')
        chat_info(receiver, username_id, {mod_cmd=mod_cmd, receiver=receiver, username=username})
      end
    end
  end

  if matches[1] == 'demote' then
    if not is_mod(msg) then
      return "Only moderator can demote."
    end
    if msg.reply_id then
      msgr = get_message(msg.reply_id, action_by_reply, {msg=msg})
    end
    if matches[2] then
      if string.match(matches[2], '^%d+$') then
        local member_username = 'user_'..matches[2]
        demote(receiver, member_username, matches[2])
      elseif string.match(matches[2], '^@.+$') then
        local username = string.gsub(matches[2], '@', '')
        if username == msg.from.username then
          return "You can't demote yourself."
        else
          chat_info(receiver, username_id, {mod_cmd=mod_cmd, receiver=receiver, username=username})
        end
      end
    end
  end

  if matches[1] == 'modlist' then
    return modlist(msg)
  end

  if matches[1] == 'adminprom' then
    if not is_admin(msg) then
      return "Only sudo can promote user as admin."
    end
    if msg.reply_id then
      msgr = get_message(msg.reply_id, action_by_reply, {msg=msg})
    end
    if matches[2] then
      if string.match(matches[2], '^%d+$') then
        local user_id = 'user_'..matches[2]
        chat_info(receiver, action_by_id, {msg=msg, matches=matches})
      elseif string.match(matches[2], '^@.+$') then
        local username = string.gsub(matches[2], '@', '')
        chat_info(receiver, username_id, {mod_cmd=mod_cmd, receiver=receiver, username=username})
      end
    end
  end

  if matches[1] == 'admindem' then
    if not is_admin(msg) then
      return "Only sudo can promote user as admin."
    end
    if msg.reply_id then
      msgr = get_message(msg.reply_id, action_by_reply, {msg=msg})
    end
    if matches[2] then
      if string.match(matches[2], '^%d+$') then
        local member_username = 'user_'..matches[2]
        admin_demote(receiver, member_username, matches[2])
      elseif string.match(matches[2], '^@.+$') then
        local username = string.gsub(matches[2], "@", "")
        chat_info(receiver, username_id, {mod_cmd=mod_cmd, receiver=receiver, username=username})
      end
    end
  end

  if matches[1] == 'adminlist' then
   if not is_admin(msg) then
      return 'Admin only!'
   end
   return admin_list(msg)
  end

  if matches[1] == 'chat_add_user' and msg.action.user.id == our_id then
    return automodadd(msg)
  end

  if matches[1] == 'chat_created' and msg.from.id == 0 then
    return automodadd(msg)
  end

end

return {
  description = "Moderation plugin",
  usage = {
    moderator = {
      "!promote : If typed when replying, promote replied user as moderator",
      "!promote <user_id> : Promote user_id as moderator",
      "!promote @<username> : Promote username as moderator",
      "!demote : If typed when replying, demote replied user from moderator",
      "!demote <user_id> : Demote user_id from moderator",
      "!demote @<username> : Demote username from moderator",
      "!modlist : List of moderators"
      },
    sudo = {
      "Following commands must be done from a group:\n\n",
      "!adminprom : If typed when replying, promote replied user as admin.",
      "!adminprom <user_id> : Promote user_id as admin.",
      "!adminprom @<username> : Promote username as admin.",
      "!admindem : If typed when replying, demote replied user from admin.",
      "!admindem <user_id> : Demote user_id from admin.",
      "!admindem @<username> : Demote username from admin."
      },
    },
  patterns = {
    "^!(admindem) (%d+)$",
    "^!(admindem) (.*)$",
    "^!(admindem)$",
    "^!(adminlist)$",
    "^!(adminprom) (%d+)$",
    "^!(adminprom) (.*)$",
    "^!(adminprom)$",
    "^!(demote) (.*)$",
    "^!(demote)$",
    "^!(modlist)$",
    "^!(promote) (.*)$",
    "^!(promote)$",
    "^!(promote) (%d+)$",
    "^!!tgservice (chat_add_user)$",
    "^!!tgservice (chat_created)$"
  },
  run = run
}

end
