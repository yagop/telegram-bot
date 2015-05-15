-- Saves the number of messages from a user
-- Can check the number of messages with !stats 

do

local NUM_MSG_MAX = 5
local TIME_CHECK = 4 -- seconds

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

-- Returns a table with `name` and `msgs`
local function get_msgs_user_chat(user_id, chat_id)
  local user_info = {}
  local uhash = 'user:'..user_id
  local user = redis:hgetall(uhash)
  local um_hash = 'msgs:'..user_id..':'..chat_id
  user_info.msgs = tonumber(redis:get(um_hash) or 0)
  user_info.name = user_print_name(user)..' ('..user_id..')'
  return user_info
end

local function get_msg_num_stats(msg)
  if msg.to.type == 'chat' then
    local chat_id = msg.to.id
    -- Users on chat
    local hash = 'chat:'..chat_id..':users'
    local users = redis:smembers(hash)
    local users_info = {}

    -- Get user info
    for i = 1, #users do
      local user_id = users[i]
      local user_info = get_msgs_user_chat(user_id, chat_id)
      table.insert(users_info, user_info)
    end

    -- Sort users by msgs number
    table.sort(users_info, function(a, b) 
        if a.msgs and b.msgs then
          return a.msgs > b.msgs
        end
      end)

    local text = ''
    for k,user in pairs(users_info) do
      text = text..user.name..' => '..user.msgs..'\n'
    end

    return text
  end
end

-- Save stats, ban user
local function pre_process(msg)
  -- Save user on Redis
  if msg.from.type == 'user' then
    local hash = 'user:'..msg.from.id
    if msg.from.print_name then
      redis:hset(hash, 'print_name', msg.from.print_name)
    end
    if msg.from.first_name then
      redis:hset(hash, 'first_name', msg.from.first_name)
    end
    if msg.from.last_name then
      redis:hset(hash, 'last_name', msg.from.last_name)
    end
  end

  -- Save stats on Redis
  if msg.to.type == 'chat' then
    -- User is on chat
    local hash = 'chat:'..msg.to.id..':users'
    redis:sadd(hash, msg.from.id)
  end

  -- Total user msgs
  local hash = 'msgs:'..msg.from.id..':'..msg.to.id
  redis:incr(hash)

  -- Check flood
  if msg.from.type == 'user' then
    local hash = 'user:'..msg.from.id..':msgs'
    local msgs = tonumber(redis:get(hash) or 0)
    if msgs > NUM_MSG_MAX then
      print('User '..msg.from.id..'is flooding '..msgs)
      msg = nil
    end
    redis:setex(hash, TIME_CHECK, msgs+1)
  end

  return msg
end

local function get_bot_stats()

  local redis_scan = [[
    local cursor = '0'
    local count = 0

    repeat
      local r = redis.call("SCAN", cursor, "MATCH", KEYS[1])
      cursor = r[1]
      count = count + #r[2]
    until cursor == '0'
    return count]]

  -- Users
  local hash = 'msgs:*:'..our_id
  local r = redis:eval(redis_scan, 1, hash)
  local text = 'Users: '..r

  hash = 'chat:*:users'
  r = redis:eval(redis_scan, 1, hash)
  text = text..'\nChats: '..r

  return text

end

local function run(msg, matches)
  if matches[1]:lower() == "stats" then
    if msg.to.type == 'chat' then
      return get_msg_num_stats(msg)
    elseif is_sudo(msg) then
      return get_bot_stats()
    else
      return 'Stats works only on chats'
    end
  end
end

return {
  description = "Plugin to update user stats.", 
  usage = "!stats: Returns a list of Username [telegram_id]: msg_num",
  patterns = {
    "^!([Ss]tats)$"
    }, 
  run = run,
  pre_process = pre_process
}

end