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
  chat_del_user(chat, user, ok_cb, true)
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

local function pre_process(msg)

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
    local user_id = msg.from.id
    local chat_id = msg.to.id
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
      print('User '..msg.from.id..' not whitelisted')
      if msg.to.type == 'chat' then
        allowed = is_chat_whitelisted(msg.to.id)
        if not allowed then
          print ('Chat '..msg.to.id..' not whitelisted')
        else
          print ('Chat '..msg.to.id..' whitelisted :)')
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
      if matches[2] == 'user' then
        ban_user(user_id, chat_id)
        return 'User '..user_id..' banned'
      end
      if matches[2] == 'delete' then
        local hash =  'banned:'..chat_id..':'..user_id
        redis:del(hash)
        return 'User '..user_id..' unbanned'
      end
    else
      return 'This isn\'t a chat group'
    end
  end

  if matches[1] == 'kick' then
    if msg.to.type == 'chat' then
      kick_user(matches[2], msg.to.id)
    else
      return 'This isn\'t a chat group'
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
    "!whitelist <enable>/<disable>: Enable or disable whitelist mode",
    "!whitelist user <user_id>: Allow user to use the bot when whitelist mode is enabled",
    "!whitelist chat: Allow everybody on current chat to use the bot when whitelist mode is enabled",
    "!whitelist delete user <user_id>: Remove user from whitelist",
    "!whitelist delete chat: Remove chat from whitelist",
    "!ban user <user_id>: Kick user from chat and kicks it if joins chat again",
    "!ban delete <user_id>: Unban user",
    "!kick <user_id> Kick user from chat group"
  },
  patterns = {
    "^!(whitelist) (enable)$",
    "^!(whitelist) (disable)$",
    "^!(whitelist) (user) (%d+)$",
    "^!(whitelist) (chat)$",
    "^!(whitelist) (delete) (user) (%d+)$",
    "^!(whitelist) (delete) (chat)$",
    "^!(ban) (user) (%d+)$",
    "^!(ban) (delete) (%d+)$",
    "^!(kick) (%d+)$",
    "^!!tgservice (.+)$",
  }, 
  run = run,
  pre_process = pre_process
}
