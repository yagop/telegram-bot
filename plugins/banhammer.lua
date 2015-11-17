-- data saved to moderation.json
do

-- make sure to set with value that not higher than stats.lua
local NUM_MSG_MAX = 5  -- Max number of messages per TIME_CHECK seconds
local TIME_CHECK = 5

local function is_anti_flood(msg)
	local data = load_data(_config.moderation.data)
	local anti_flood_stat = data[tostring(msg.to.id)]['settings']['anti_flood']
	if anti_flood_stat == 'kick' or anti_flood_stat == 'ban' then
		return true
	else
		return false
	end
end

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

local function is_banned(user_id, chat_id)
  local hash =  'banned:'..chat_id..':'..user_id
  local banned = redis:get(hash)
  return banned or false
end

local function action_by_reply(extra, success, result)
  local msg = result
  local chat = msg.to.id
  local user = msg.from.id
  if result.to.type == 'chat' and not is_sudo(msg) then
    if extra.match == 'kick' then
      chat_del_user('chat#id'..chat, 'user#id'..user, ok_cb, false)
    elseif extra.match == 'ban' then
      -- Save to redis
      local hash =  'banned:'..chat..':'..user
      redis:set(hash, true)
      chat_del_user('chat#id'..chat, 'user#id'..user, ok_cb, false)
      send_msg(chat, 'User '..user..' banned', ok_cb,  true)
    end
  else
    return 'Use This in Your Groups'
  end
end

local function res_user_callback(extra, success, result)
  --vardump(extra)
  local msg = extra.msg
  local chat = msg.to.id
  local user = result.id
  if msg.to.type == 'chat' then
    -- check if user is a sudoer
    for v,user_id in pairs(_config.sudo_users) do
      if user_id ~= user then
        if extra.match == 'kick' then
          chat_del_user('chat#id'..chat, 'user#id'..user, ok_cb, false)
        elseif extra.match == 'ban' then
          -- Save to redis
          local hash =  'banned:'..chat..':'..user
          redis:set(hash, true)
          chat_del_user('chat#id'..chat, 'user#id'..user, ok_cb, false)
        elseif extra.match == 'delete' then
          local hash =  'banned:'..chat..':'..user
          redis:del(hash)
        end
      end
    end
  else
    return 'Use This in Your Groups'
  end
end

local function pre_process(msg)

  local user_id = msg.from.id
  local chat_id = msg.to.id

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
        send_msg('chat#id'..chat_id, 'User '..user_id..' banned', ok_cb,  true)
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
      local banned = is_banned(user_id, msg.to.id)
      if banned then
        print('User is banned!')
        kick_user(user_id, msg.to.id)
      end
    end
    -- No further checks
    return msg
  end

  -- BANNED USER TALKING
  if msg.to.type == 'chat' then
    local banned = is_banned(user_id, chat_id)
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
    local allowed = is_user_whitelisted(msg.from.id)

    if not allowed then
      print('User '..user_id..' not whitelisted')
      if msg.to.type == 'chat' then
        allowed = is_chat_whitelisted(msg.to.id)
        if not allowed then
          print ('Chat '..chat_id..' not whitelisted')
        else
          print ('Chat '..chat_id..' whitelisted :)')
        end
      end
    else
      print('User '..msg.from.id..' allowed :)')
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

  -- Silent ignore
  if not is_sudo(msg) then
    return nil
  end

  if matches[1] == 'ban' then
    local user_id = matches[3]
    local chat_id = msg.to.id

    if msg.to.type == 'chat' then
      if msg.reply_id then
        msgr = get_message(msg.reply_id, action_by_reply, {msg=msg, match=matches[1]})
      elseif string.match(matches[2], '^%d+$') then
        ban_user(matches[2], chat_id)
        return 'User '..matches[2]..' banned'
      elseif string.match(matches[2], '^@.+$') then
        local user = string.gsub(matches[2], '@', '')
        msgr = res_user(user, res_user_callback, {msg=msg, match=matches[1]})
        return 'User '..matches[2]..' banned'
      end

      if matches[2] == 'delete' then
        if string.match(user_id, '^@.+$') then
          local user = string.gsub(user_id, '@', '')
          msgr = res_user(user, res_user_callback, {msg=msg, match=matches[2]})
        else
          local hash =  'banned:'..chat_id..':'..user_id
          redis:del(hash)
        end
        return 'User '..user_id..' unbanned'
      end
    else
      return 'This isn\'t a chat group'
    end
  end

  if matches[1] == 'kick' then
    if msg.to.type == 'chat' then
      if msg.reply_id then
        msgr = get_message(msg.reply_id, action_by_reply, {msg=msg, match=matches[1]})
      elseif string.match(matches[2], '^%d+$') then
        kick_user(matches[2], msg.to.id)
      else
        local user = string.gsub(matches[2], '@', '')
        msgr = res_user(user, res_user_callback, {msg=msg, match=matches[1]})
      end
    else
      return 'This isn\'t a chat group'
    end
  end

  if matches[1] == 'antiflood' then
  local data = load_data(_config.moderation.data)
  local anti_flood_stat = data[tostring(msg.to.id)]['settings']['anti_flood']
    if matches[2] == 'kick' then
      if anti_flood_stat ~= 'kick' then
        data[tostring(msg.to.id)]['settings']['anti_flood'] = 'kick'
        save_data(_config.moderation.data, data)
      end
      return 'Anti flood protection already enabled.\nFlooder will be kicked.'
    end
    if matches[2] == 'ban' then
      if anti_flood_stat ~= 'ban' then
        data[tostring(msg.to.id)]['settings']['anti_flood'] = 'ban'
        save_data(_config.moderation.data, data)
      end
      return 'Anti flood  protection already enabled.\nFlooder will be banned.'
    end
    if matches[2] == 'disable' then
      if anti_flood_stat == 'no' then
        return 'Anti flood  protection is not enabled.'
      else
        data[tostring(msg.to.id)]['settings']['anti_flood'] = 'no'
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
        return 'This isn\'t a chat group'
      end
      local hash = 'whitelist:chat#id'..msg.to.id
      redis:set(hash, true)
      return 'Chat '..msg.to.id..' whitelisted'
    end

    if matches[2] == 'delete' and matches[3] == 'user' then
      local hash = 'whitelist:user#id'..matches[4]
      redis:del(hash)
      return 'User '..matches[4]..' removed from whitelist'
    end

    if matches[2] == 'delete' and matches[3] == 'chat' then
      if msg.to.type ~= 'chat' then
        return 'This isn\'t a chat group'
      end
      local hash = 'whitelist:chat#id'..msg.to.id
      redis:del(hash)
      return 'Chat '..msg.to.id..' removed from whitelist'
    end

  end
end

return {
  description = "Plugin to manage bans, kicks and white/black lists.",
  usage = {
    "!antiflood kick : Enable flood protection. Flooder will be kicked.",
    "!antiflood ban : Enable flood protection. Flooder will be banned.",
    "!antiflood disable : Disable flood protection",
    "!ban : If type in reply, will ban user from chat group.",
    "!ban delete <user_id>/<@username>: Unban user",
    "!ban <user_id>/<@username>: Kick user from chat and kicks it if joins chat again",
    "!kick : If type in reply, will kick user from chat group.",
    "!kick <user_id>/<@username>: Kick user from chat group",
    "!whitelist chat: Allow everybody on current chat to use the bot when whitelist mode is enabled",
    "!whitelist delete chat: Remove chat from whitelist",
    "!whitelist delete user <user_id>: Remove user from whitelist",
    "!whitelist <enable>/<disable>: Enable or disable whitelist mode",
    "!whitelist user <user_id>: Allow user to use the bot when whitelist mode is enabled"
  },
  patterns = {
    "^!(antiflood) (.*)$",
    "^!(ban) (@.+)$",
    "^!(ban)$",
    "^!(ban) (%d+)$",
    "^!(ban) (delete) (@.+)$",
    "^!(ban) (delete) (%d+)$",
    "^!(kick) (.+)$",
    "^!(kick)$",
    "^!!tgservice (.+)$",
    "^!(whitelist) (chat)$",
    "^!(whitelist) (delete) (chat)$",
    "^!(whitelist) (delete) (user) (%d+)$",
    "^!(whitelist) (disable)$",
    "^!(whitelist) (enable)$",
    "^!(whitelist) (user) (%d+)$"
  },
  run = run,
  pre_process = pre_process,
  privileged = true
}

end
