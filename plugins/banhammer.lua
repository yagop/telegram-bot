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

local function is_user_blacklisted(id)
  local hash = 'blacklist:user#id'..id
  local black = redis:get(hash) or false
  return black
end

local function is_chat_blacklisted(id)
  local hash = 'blacklist:chat#id'..id
  local black = redis:get(hash) or false
  return black
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
  
  -- WHITELIST AND BLACKLIST
  local whitehash = 'whitelist:enabled'
  local blackhash = 'blacklist:enabled'
  local whitelist = redis:get(whitehash) == 'true'
  local blacklist = redis:get(blackhash) == 'true'
  local issudo = is_sudo(msg)

  -- Allow all sudo users even if whitelist is allowed
  if not issudo then
    local allowed = true
    if whitelist then
      print('Whitelist enabled')
      -- Check if user or chat is whitelisted
      allowed = is_user_whitelisted(msg.from.id)
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
        print('User '..msg.from.id..' whitelisted :)')
      end
      if not allowed then
        msg.text = ''
      end

    elseif blacklist then 
		print('Blacklist enabled')
	   -- Check if user or chat is blacklisted
		if msg.to.type == 'chat' then
    	  allowed = not is_chat_blacklisted(msg.to.id)
    	  if not allowed then
          print('Chat '..msg.to.id..' blacklisted')
          msg.text = ''
        else
          print('Chat '..msg.to.id..' not blacklisted :)')
		  end
      end
		if allowed then
        allowed = not is_user_blacklisted(msg.from.id)
		  if not allowed then
          print('User '..msg.from.id..' blacklisted')
			 msg.text = ''
        else
          print('User '..msg.from.id..' not blacklisted :)')
		  end
		end
	 
	 else
	   print('White/black list not enabled')
    end
  else
    print('User is sudo')
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

  if matches[2] == 'show' then
    local list
    if matches[1] == 'whitelist' then
      list = 'whitelist'
    elseif matches[1] == 'blacklist' then
	   list = 'blacklist'
	 end

    local retmsg = 'Status: '
    local hash = list..':enabled'
    retmsg = retmsg .. (redis:get(hash) == 'true' and 'enabled' or 'disabled') .. '\n'
    hash = list..':user*'
    local keys = redis:keys(hash)
	 if next(keys) then
	   retmsg = retmsg .. list .. 'ed users:'
	 end
	 for k,v in pairs(keys) do
      retmsg = retmsg .. '\n' .. string.match(v,"#id(.*)")
	 end
    hash = list..':chat*'
    local keys = redis:keys(hash)
	 if next(keys) then 
	   retmsg = retmsg .. '\n' .. list .. 'ed chats:'
	 end
	 for k,v in pairs(keys) do
      retmsg = retmsg .. '\n' .. string.match(v,"#id(.*)")
	 end
    return retmsg
  end

  if matches[1] == 'banhammer' then
    local hash
    if matches[2] == 'enable' then
	   if matches[3] == 'whitelist' then
        hash = 'whitelist:enabled'
        redis:set(hash, true)
		  hash = 'blacklist:enabled'
		  redis:set(hash, false)
        return 'Enabled whitelist'
	   elseif matches[3] == 'blacklist' then
        hash = 'blacklist:enabled'
		  redis:set(hash, true)
		  hash = 'whitelist:enabled'
		  redis:set(hash, false)
		  return 'Enabled blacklist'
		end
    elseif matches[2] == 'disable' then
      hash = 'whitelist:enabled'
		redis:set(hash, false)
		hash = 'blacklist:enabled'
		redis:set(hash, false)
		return 'Whitelist/blacklist disabled'
	 end
  end

  if matches[1] == 'whitelist' then
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
  
  if matches[1] == 'blacklist' then
    if matches[2] == 'user' then
      local hash = 'blacklist:user#id'..matches[3]
      redis:set(hash, true)
      return 'User '..matches[3]..' blacklisted'
    end

    if matches[2] == 'chat' then
      if msg.to.type ~= 'chat' then
        return 'This isn\'t a chat group'
      end
      local hash = 'blacklist:chat#id'..msg.to.id
      redis:set(hash, true)
      return 'Chat '..msg.to.id..' blacklisted'
    end

    if matches[2] == 'delete' and matches[3] == 'user' then
      local hash = 'blacklist:user#id'..matches[4]
      redis:del(hash)
      return 'User '..matches[4]..' removed from blacklist'
    end

    if matches[2] == 'delete' and matches[3] == 'chat' then
      if msg.to.type ~= 'chat' then
        return 'This isn\'t a chat group'
      end
      local hash = 'blacklist:chat#id'..msg.to.id
      redis:del(hash)
      return 'Chat '..msg.to.id..' removed from blacklist'
    end

  end
end

return {
  description = "Plugin to manage bans, kicks and white/black lists.", 
  usage = {
    "!banhammer <enable>/<disable> whitelist/blacklist: Enable or disable whitelist/blacklist mode",
    "!whitelist user <user_id>: Allow user to use the bot when whitelist mode is enabled",
    "!whitelist chat: Allow everybody on current chat to use the bot when whitelist mode is enabled",
    "!whitelist delete user <user_id>: Remove user from whitelist",
    "!whitelist delete chat: Remove chat from whitelist",
	 "!whitelist show: Print whitelist status and content",
    "!blacklist user <user_id>: Prevent user to use the bot when blacklist mode is enabled",
    "!blacklist chat: Prevent everybody on current chat to use the bot when blacklist mode is enabled",
    "!blacklist delete user <user_id>: Remove user from blacklist",
    "!blacklist delete chat: Remove chat from blacklist",
	 "!blacklist show: Print blacklist status and content",
    "!ban user <user_id>: Kick user from chat and kicks it if joins chat again",
    "!ban delete <user_id>: Unban user",
    "!kick <user_id> Kick user from chat group"
  },
  patterns = {
    "^!(banhammer) (enable) (whitelist)$",
    "^!(banhammer) (enable) (blacklist)$",
    "^!(banhammer) (disable)$",
    "^!(whitelist) (user) (%d+)$",
    "^!(whitelist) (chat)$",
    "^!(whitelist) (delete) (user) (%d+)$",
    "^!(whitelist) (delete) (chat)$",
	 "^!(whitelist) (show)",
    "^!(blacklist) (user) (%d+)$",
    "^!(blacklist) (chat)$",
    "^!(blacklist) (delete) (user) (%d+)$",
    "^!(blacklist) (delete) (chat)$",
	 "^!(blacklist) (show)",
    "^!(ban) (user) (%d+)$",
    "^!(ban) (delete) (%d+)$",
    "^!(kick) (%d+)$",
    "^!!tgservice (.+)$",
  }, 
  run = run,
  pre_process = pre_process
}
