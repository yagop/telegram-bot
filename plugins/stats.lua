-- Saves the number of messages from a user
-- Can check the number of messages with !stats 

do

local NUM_MSG_MAX = 2
local TIME_CHECK = 2 -- seconds

local function get_stats(msg)
  if msg.to.type == 'chat' then
    local name = get_name(msg)
    local hash = 'chat:'..msg.to.id..':stats'
    local stats = redis:zrange(hash, 0, -1, 'withscores')
    local text = ''
    for k,v in pairs(stats) do
      text = text..v[1]..': \t '..v[2]
    end
    return text
  end
end

-- Save stats, ban user
local function pre_process(msg)
    -- Save stats on Redis
  if msg and msg.to.type == 'chat' then
    local name = get_name(msg)
    local hash = 'chat:'..msg.to.id..':stats'
    -- TODO: User id
    redis:zincrby(hash, 1, name)
  end
  
  -- Check flood
  if msg.from.type == 'user' then
    local hash = 'flood:user:'..msg.from.id
    local msgs = tonumber(redis:get(hash) or 0)
    if msgs > NUM_MSG_MAX then
      print('User '..msg.from.id..'is flooding '..msgs)
      redis:setex(hash, TIME_CHECK, msgs+1)
      msg = nil
    end
    redis:setex(hash, TIME_CHECK, msgs+1)
  end

  return msg
end

local function run(msg, matches)
  if matches[1] == "stats" and is_sudo(msg) then
    if msg.to.type == 'chat' then
      return get_stats(msg)
    else
      return 'Stats works only on chats'
    end
  end
end

return {
  description = "Plugin to update user stats.", 
  usage = "!stats: Returns a list of Username [telegram_id]: msg_num",
  patterns = {
    "^!(stats)"
    }, 
  run = run,
  pre_process = pre_process
}

end
