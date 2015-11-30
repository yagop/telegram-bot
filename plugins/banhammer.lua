-- data saved to moderation.json
do

-- make sure to set with value that not higher than stats.lua
local NUM_MSG_MAX = 4  -- Max number of messages per TIME_CHECK seconds
local TIME_CHECK = 4

local function is_user_whitelisted(id)
  local hash = 'whitelist:user#id'..id
  local white = redis:get(hash) or false
  return white
end

local function is_chat_whitelisted(id)
  local hash = 'whitelist:chat#id'..id
  local white = redis:get(hash) or false
  return white
end

local function kick_user(user_id, chat_id)
  local chat = 'chat#id'..chat_id
  local user = 'user#id'..user_id

  if user_id == tostring(our_id) then
    send_msg(chat, "I won't kick myself!", ok_cb,  true)
  else
    chat_del_user(chat, user, ok_cb, true)
  end
end

local function ban_user(user_id, chat_id)
  -- Save to redis
  local hash =  'banned:'..chat_id..':'..user_id
  redis:set(hash, true)
  -- Kick from chat
  kick_user(user_id, chat_id)
end

local function superban_user(user_id, chat_id)
  -- Save to redis
  local hash =  'superbanned:'..user_id
  redis:set(hash, true)
  -- Kick from chat
  kick_user(user_id, chat_id)
end

local function is_super_banned(user_id)
    local hash = 'superbanned:'..user_id
    local superbanned = redis:get(hash)
    return superbanned or false
end

local function unban_user(user_id, chat_id)
  local hash = 'banned:'..chat_id..':'..user_id
  redis:del(hash)
end

local function superunban_user(user_id, chat_id)
  local hash =  'superbanned:'..user_id
  redis:del(hash)
  return 'User '..user_id..' unbanned'
end

local function is_banned(user_id, chat_id)
  local hash =  'banned:'..chat_id..':'..user_id
  local banned = redis:get(hash)
  return banned or false
end

local function action_by_id(extra, success, result)
  if success == 1 then
    local matches = extra.matches
    local chat_id = result.id
    local chat = 'chat#id'..chat_id
    local member = matches[2]
    for k,v in pairs(result.members) do
      vuserid = tostring(v.id)
      if matches[2] == vuserid then
        lift_ban = false
        local full_name = (v.first_name or '')..' '..(v.last_name or '')
        local user_id = vuserid
        if matches[1] == 'ban' then
          ban_user(user_id, chat_id)
          send_large_msg(chat, full_name..' ['..user_id..'] banned', ok_cb,  true)
        elseif matches[1] == 'superban' then
          superban_user(user_id, chat_id)
          send_large_msg(chat, full_name..' ['..user_id..'] globally banned!', ok_cb, true)
        elseif matches[1] == 'kick' then
          kick_user(user_id, chat_id)
        end
      end
    end
    if matches[1] == 'unban' then
      lift_ban = true
      if is_banned(member, chat_id) then
        unban_user(member, chat_id)
        send_large_msg(chat, 'User with ID ['..member..'] is unbanned.')
      else
        send_large_msg(chat, 'No user with ID '..member..' in (super)ban list.')
      end
    elseif matches[1] == 'superunban' then
      lift_ban = true
      if is_super_banned(member) then
        superunban_user(member, chat_id)
        send_large_msg(chat, 'User with ID ['..member..'] is globally unbanned.')
      else
        send_large_msg(chat, 'No user with ID '..member..' in (super)ban list.')
      end
    end
    if not lift_ban then
      send_large_msg(chat, 'No user with ID '..member..' in this group.')
    end
  end
end

local function action_by_reply(extra, success, result)
  local msg = result
  local chat_id = msg.to.id
  local user_id = msg.from.id
  local chat = 'chat#id'..msg.to.id
  local user = 'user#id'..msg.from.id
  local full_name = (msg.from.first_name or '')..' '..(msg.from.last_name or '')
  local receiver = get_receiver(msg)
  if result.to.type == 'chat' and not is_sudo(msg) then
    if extra.match == 'kick' then
      chat_del_user(chat, user, ok_cb, false)
    elseif extra.match == 'ban' then
      ban_user(user_id, chat_id)
      send_msg(chat, 'User '..user_id..' banned', ok_cb,  true)
    elseif extra.match == 'superban' then
      superban_user(user_id, chat_id)
      send_large_msg(receiver, full_name..' ['..user_id..'] globally banned!')
    elseif extra.match == 'unban' then
      unban_user(user_id, chat_id)
      send_msg(chat, 'User '..user_id..' unbanned', ok_cb,  true)
    elseif extra.match == 'superunban' then
      superunban_user(user_id, chat_id)
      send_large_msg(receiver, full_name..' ['..user_id..'] globally unbanned!')
    end
  else
    return 'Use This in Your Groups'
  end
end

local function resolve_username(extra, success, result)
  local msg = extra.msg
  local chat_id = msg.to.id
  local chat = 'chat#id'..msg.to.id
  if result ~= false then
    local user_id = result.id
    local user = 'user#id'..result.id
    local username = result.username
    if msg.to.type == 'chat' then
      -- check if sudo users
      local is_sudoers = false
      for v,username in pairs(_config.sudo_users) do
        if username == user_id then
          is_sudoers = true
        end
      end
      if not is_sudoers then
        if extra.match == 'kick' then
          chat_del_user(chat, user, ok_cb, false)
        elseif extra.match == 'ban' then
          ban_user(user_id, chat_id)
          send_msg(chat, 'User @'..username..' banned', ok_cb,  true)
        elseif extra.match == 'superban' then
          superban_user(user_id, chat_id)
          send_msg(chat, 'User @'..username..' ['..user_id..'] globally banned!', ok_cb,  true)
        elseif extra.match == 'unban' then
          unban_user(user_id, chat_id)
          send_msg(chat, 'User @'..username..' unbanned', ok_cb,  true)
        elseif extra.match == 'superunban' then
          superunban_user(user_id, chat_id)
          send_msg(chat, 'User @'..username..' ['..user_id..'] globally unbanned!', ok_cb,  true)
        end
      end
    else
      return 'Use This in Your Groups.'
    end
  else
    send_large_msg(chat, 'No user @'..extra.user..' in this group.')
  end
end

local function pre_process(msg)

  local user_id = msg.from.id
  local chat_id = msg.to.id
  local chat = 'chat#id'..chat_id
  local user = 'user#id'..user_id

  -- ANTI FLOOD
  local post_count = 'floodc:'..user_id..':'..chat_id
  redis:incr(post_count)
  if msg.from.type == 'user' then
    local post_count = 'user:'..user_id..':floodc'
    local msgs = tonumber(redis:get(post_count) or 0)
    local text = 'User '..user_id..' is flooding'
    if msgs > NUM_MSG_MAX and not is_sudo(msg) then
      local data = load_data(_config.moderation.data)
      local anti_flood_stat = data[tostring(chat_id)]['settings']['anti_flood']
      if anti_flood_stat == 'kick' then
        send_large_msg(get_receiver(msg), text)
        kick_user(user_id, chat_id)
        msg = nil
      elseif anti_flood_stat == 'ban' then
        send_large_msg(get_receiver(msg), text)
        ban_user(user_id, chat_id)
        send_msg(chat, 'User '..user_id..' banned', ok_cb,  true)
        msg = nil
      end
    end
    redis:setex(post_count, TIME_CHECK, msgs+1)
  end

  -- SERVICE MESSAGE
  if msg.action and msg.action.type then
    local action = msg.action.type
    -- Check if banned user joins chat
    if action == 'chat_add_user' or action == 'chat_add_user_link' then
      local user_id
      if msg.action.link_issuer then
        user_id = msg.from.id
      else
	      user_id = msg.action.user.id
      end
      print('Checking invited user '..user_id)
      local superbanned = is_super_banned(user_id)
      local banned = is_banned(user_id, chat_id)
      if superbanned or banned then
        print('User is banned!')
        kick_user(user_id, chat_id)
      end
    end
    -- No further checks
    return msg
  end

  -- BANNED USER TALKING
  if msg.to.type == 'chat' then
    local superbanned = is_super_banned(user_id)
    local banned = is_banned(user_id, chat_id)
    if superbanned then
      print('SuperBanned user talking!')
      superban_user(user_id, chat_id)
      msg.text = ''
    end
    if banned then
      print('Banned user talking!')
      ban_user(user_id, chat_id)
      msg.text = ''
    end
  end

  -- WHITELIST
  local hash = 'whitelist:enabled'
  local whitelist = redis:get(hash)
  local issudo = is_sudo(msg)

  -- Allow all sudo users even if whitelist is allowed
  if whitelist and not issudo then
    print('Whitelist enabled and not sudo')
    -- Check if user or chat is whitelisted
    local allowed = is_user_whitelisted(user_id)

    if not allowed then
      print('User '..user..' not whitelisted')
      if msg.to.type == 'chat' then
        allowed = is_chat_whitelisted(chat_id)
        if not allowed then
          print ('Chat '..chat_id..' not whitelisted')
        else
          print ('Chat '..chat_id..' whitelisted :)')
        end
      end
    else
      print('User '..user_id..' allowed :)')
    end

    if not allowed then
      msg.text = ''
    end

  else
    print('Whitelist not enabled or is sudo')
  end

  return msg
end

local function run(msg, matches)

  local user_id = matches[2]
  local chat_id = msg.to.id
  local chat = 'chat#id'..chat_id
  local user = 'user#id'..(user_id or '')

  if msg.to.type == 'chat' then
    if matches[1] == 'kickme' then
      if is_sudo(msg) or is_admin(msg) then
        return "I won't kick an admin!"
      elseif is_mod(msg) then
        return "I won't kick a moderator!"
      else
        kick_user(msg.from.id, chat_id)
      end
    end

    -- Silent ignore
    if not is_mod(msg) then
      return nil
    end

    if matches[1] == 'ban' then
      if msg.reply_id then
        msgr = get_message(msg.reply_id, action_by_reply, {msg=msg, match=matches[1]})
      elseif string.match(user_id, '^%d+$') then
        chat_info(chat, action_by_id, {msg=msg, matches=matches})
      elseif string.match(user_id, '^@.+$') then
        local user = string.gsub(user_id, '@', '')
        msgr = res_user(user, resolve_username, {msg=msg, match=matches[1]})
      end
    elseif matches[1] == 'superban' and is_admin(msg) then
      if msg.reply_id then
        msgr = get_message(msg.reply_id, action_by_reply, {msg=msg, match=matches[1]})
      elseif string.match(user_id, '^%d+$') then
        chat_info(chat, action_by_id, {msg=msg, matches=matches})
      elseif string.match(user_id, '^@.+$') then
        local user = string.gsub(user_id, '@', '')
        msgr = res_user(user, resolve_username, {msg=msg, match=matches[1], user=user})
      end
    elseif matches[1] == 'unban' then
      if msg.reply_id then
        msgr = get_message(msg.reply_id, action_by_reply, {msg=msg, match=matches[1]})
      elseif string.match(user_id, '^%d+$') then
        chat_info(chat, action_by_id, {msg=msg, matches=matches})
      elseif string.match(user_id, '^@.+$') then
        local user = string.gsub(user_id, '@', '')
        msgr = res_user(user, resolve_username, {msg=msg, match=matches[1]})
      end
    elseif matches[1] == 'superunban' and is_admin(msg) then
      if msg.reply_id then
        msgr = get_message(msg.reply_id, action_by_reply, {msg=msg, match=matches[1]})
      elseif string.match(user_id, '^%d+$') then
        chat_info(chat, action_by_id, {msg=msg, matches=matches})
      elseif string.match(user_id, '^@.+$') then
        local user = string.gsub(user_id, '@', '')
        msgr = res_user(user, resolve_username, {msg=msg, match=matches[1]})
      end
    elseif matches[1] == 'kick' then
      if msg.reply_id then
        msgr = get_message(msg.reply_id, action_by_reply, {msg=msg, match=matches[1]})
      elseif string.match(user_id, '^%d+$') then
        chat_info(chat, action_by_id, {msg=msg, matches=matches})
      elseif string.match(user_id, '^@.+$') then
        local user = string.gsub(user_id, '@', '')
        msgr = res_user(user, resolve_username, {msg=msg, match=matches[1]})
      end
    end
  else
    return 'This is not a chat group.'
  end

  if matches[1] == 'antiflood' then
  local data = load_data(_config.moderation.data)
  local anti_flood_stat = data[tostring(chat_id)]['settings']['anti_flood']
    if matches[2] == 'kick' then
      if anti_flood_stat ~= 'kick' then
        data[tostring(chat_id)]['settings']['anti_flood'] = 'kick'
        save_data(_config.moderation.data, data)
      end
      return 'Anti flood protection already enabled.\nFlooder will be kicked.'
    end
    if matches[2] == 'ban' then
      if anti_flood_stat ~= 'ban' then
        data[tostring(chat_id)]['settings']['anti_flood'] = 'ban'
        save_data(_config.moderation.data, data)
      end
      return 'Anti flood  protection already enabled.\nFlooder will be banned.'
    end
    if matches[2] == 'disable' then
      if anti_flood_stat == 'no' then
        return 'Anti flood  protection is not enabled.'
      else
        data[tostring(chat_id)]['settings']['anti_flood'] = 'no'
        save_data(_config.moderation.data, data)
        return 'Anti flood  protection has been disabled.'
      end
    end
  end

  if matches[1] == 'whitelist' then
    if matches[2] == 'enable' then
      local hash = 'whitelist:enabled'
      redis:set(hash, true)
      return 'Enabled whitelist'
    end

    if matches[2] == 'disable' then
      local hash = 'whitelist:enabled'
      redis:del(hash)
      return 'Disabled whitelist'
    end

    if matches[2] == 'user' then
      local hash = 'whitelist:user#id'..matches[3]
      redis:set(hash, true)
      return 'User '..matches[3]..' whitelisted'
    end

    if matches[2] == 'chat' then
      if msg.to.type ~= 'chat' then
        return 'This is not a chat group'
      end
      local hash = 'whitelist:chat#id'..chat_id
      redis:set(hash, true)
      return 'Chat '..chat_id..' whitelisted'
    end

    if matches[2] == 'delete' and matches[3] == 'user' then
      local hash = 'whitelist:user#id'..matches[4]
      redis:del(hash)
      return 'User '..matches[4]..' removed from whitelist'
    end

    if matches[2] == 'delete' and matches[3] == 'chat' then
      if msg.to.type ~= 'chat' then
        return 'This is not a chat group'
      end
      local hash = 'whitelist:chat#id'..chat_id
      redis:del(hash)
      return 'Chat '..chat_id..' removed from whitelist'
    end

  end
end

return {
  description = "Plugin to manage bans, kicks and white/black lists.",
  usage = {
    admin = {
      "!superban : If type in reply, will ban user globally.",
      "!superban <user_id>/@<username> : Kick user_id/username from all chat and kicks it if joins again",
      "!superunban : If type in reply, will unban user globally.",
      "!superunban <user_id>/@<username> : Unban user_id/username globally."
    },
    moderator = {
      "!antiflood kick : Enable flood protection. Flooder will be kicked.",
      "!antiflood ban : Enable flood protection. Flooder will be banned.",
      "!antiflood disable : Disable flood protection",
      "!ban : If type in reply, will ban user from chat group.",
      "!ban <user_id>/<@username>: Kick user from chat and kicks it if joins chat again",
      "!unban : If type in reply, will unban user from chat group.",
      "!unban <user_id>/<@username>: Unban user",
      "!kick : If type in reply, will kick user from chat group.",
      "!kick <user_id>/<@username>: Kick user from chat group",
      "!whitelist chat: Allow everybody on current chat to use the bot when whitelist mode is enabled",
      "!whitelist delete chat: Remove chat from whitelist",
      "!whitelist delete user <user_id>: Remove user from whitelist",
      "!whitelist <enable>/<disable>: Enable or disable whitelist mode",
      "!whitelist user <user_id>: Allow user to use the bot when whitelist mode is enabled"
    },
  },
  patterns = {
    "^!(antiflood) (.*)$",
    "^!(ban) (.*)$",
    "^!(ban)$",
    "^!(unban) (.*)$",
    "^!(unban)$",
    "^!(kick) (.+)$",
    "^!(kick)$",
    "^!(kickme)$",
    "^!!tgservice (.+)$",
    "^!(whitelist) (chat)$",
    "^!(whitelist) (delete) (chat)$",
    "^!(whitelist) (delete) (user) (%d+)$",
    "^!(whitelist) (disable)$",
    "^!(whitelist) (enable)$",
    "^!(whitelist) (user) (%d+)$",
    "^!(superban)$",
    "^!(superban) (.*)$",
    "^!(superunban)$",
    "^!(superunban) (.*)$"
  },
  run = run,
--  privileged = true
  pre_process = pre_process
}

end
