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

local function pre_process(msg)

  local user = msg.from.id
  local chat = msg.to.id
  local hash = 'floodc:'..user..':'..chat
  redis:incr(hash)
  if msg.from.type == 'user' then
    local hash = 'user:'..user..':floodc'
    local msgs = tonumber(redis:get(hash) or 0)
    local text = 'User '..user..' is flooding'
    if msgs > NUM_MSG_MAX and not is_sudo(msg) then
      local data = load_data(_config.moderation.data)
      local anti_flood_stat = data[tostring(chat)]['settings']['anti_flood']
      if anti_flood_stat == 'kick' then
        send_large_msg(get_receiver(msg), text)
        chat_del_user('chat#id'..chat, 'user#id'..user, ok_cb, true)
        msg = nil
      elseif anti_flood_stat == 'ban' then
        send_large_msg(get_receiver(msg), text)
        -- Save to redis
        local hash =  'banned:'..chat..':'..user
        redis:set(hash, true)
        chat_del_user('chat#id'..chat, 'user#id'..user, ok_cb, true)
        send_msg('chat#id'..chat, 'User '..user..' banned', ok_cb,  true)
        msg = nil
      end
    end
    redis:setex(hash, TIME_CHECK, msgs+1)
  end
  return msg
end

function run(msg, matches)

  if not is_sudo(msg) then
    return "For moderators only!"
  end

  if matches[1] == 'antiflood' then
  local data = load_data(_config.moderation.data)
    if matches[2] == 'kick' then
      local anti_flood_stat = data[tostring(msg.to.id)]['settings']['anti_flood']
      if anti_flood_stat == 'kick' then
        return 'Anti flood protection already enabled.\nFlooder will be kicked.'
      else
        data[tostring(msg.to.id)]['settings']['anti_flood'] = 'kick'
        save_data(_config.moderation.data, data)
      end
      return 'Anti flood  protection has been enabled.\nFlooder will be kicked.'
    end
    if matches[2] == 'ban' then
      local anti_flood_stat = data[tostring(msg.to.id)]['settings']['anti_flood']
      if anti_flood_stat == 'ban' then
        return 'Anti flood  protection already enabled.\nFlooder will be banned.'
      else
        data[tostring(msg.to.id)]['settings']['anti_flood'] = 'ban'
        save_data(_config.moderation.data, data)
      end
      return 'Anti flood  protection has been enabled.\nFlooder will be banned.'
    end
    if matches[2] == 'disable' then
      local anti_flood_stat = data[tostring(msg.to.id)]['settings']['anti_flood']
      if anti_flood_stat == 'no' then
        return 'Anti flood  protection is not enabled.'
      else
        data[tostring(msg.to.id)]['settings']['anti_flood'] = 'no'
        save_data(_config.moderation.data, data)
        return 'Anti flood  protection has been disabled.'
      end
    end
  end
end

return {
  description = "Plugin to kick flooders from group.",
  usage = {
    "!antiflood <kick> : Enable flood protection. Flooder will be kicked.",
    "!antiflood <ban> : Enable flood protection. Flooder will be banned.",
    "!antiflood <disable> : Disable flood protection"
  },
  patterns = {
    "^!(antiflood) (.*)$"
  },
  run = run,
  privileged = true,
  pre_process = pre_process
}

end
