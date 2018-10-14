-- Saves the number of messages from a user
-- Can check the number of messages with !stats

do

  local NUM_MSG_MAX = 5
  local TIME_CHECK = 4 -- seconds

  local function user_print_name(user)
    local text = ''

    if user.first_name then
      text = user.first_name .. ' '
    end
    if user.last_name then
      text = text .. user.last_name
    end
    return text
  end

  -- Returns a table with `name` and `msgs`
  local function get_msgs_user_chat(user_id, chat_id)
    local user_info = {}
    local uhash = 'user:' .. user_id
    local user = redis:hgetall(uhash)
    local um_hash = 'msgs:' .. user_id .. ':' .. chat_id
    user_info.msgs = tonumber(redis:get(um_hash) or 0)
    user_info.id = user_id
    user_info.name = user_print_name(user)
    return user_info
  end

  local function chat_stats(msg, chat_id)
    -- Users on chat
    local hash = 'chat:' .. chat_id .. ':users'
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
      text = text .. '*' .. k .. '*. `' .. user.id .. '` - ' .. markdown_escape(user.name) .. ' = *' .. user.msgs .. '*\n'
    end
    bot_sendMessage(get_receiver_api(msg), text, true, msg.id, 'markdown')
  end

--------------------------------------------------------------------------------

  -- Save stats, ban user
  local function pre_process(msg)
    -- Ignore service msg
    if msg.service then
      print('Service message')
      return msg
    end

    -- Save user on Redis
    if msg.from.peer_type == 'user' then
      local hash = 'user:' .. msg.from.peer_id
      print('Saving user', hash)
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
    if msg.to.peer_type == 'chat' or msg.to.peer_type == 'channel' then
      -- User is on chat
      local hash = 'chat:' .. msg.to.peer_id .. ':users'
      redis:sadd(hash, msg.from.peer_id)
    end

    -- Total user msgs
    local hash = 'msgs:' .. msg.from.peer_id .. ':' .. msg.to.peer_id
    redis:incr(hash)

    -- Check flood
    if msg.from.peer_type == 'user' then
      local hash = 'user:' .. msg.from.peer_id .. ':msgs'
      local msgs = tonumber(redis:get(hash) or 0)

      if msgs > NUM_MSG_MAX then
        print('User ' .. msg.from.peer_id .. ' is flooding ' .. msgs)
        msg = nil
      end
      redis:setex(hash, TIME_CHECK, msgs+1)
    end

    return msg
  end

  local function bot_stats()

    local redis_scan = [[
      local cursor = '0'
      local count = 0

      repeat
        local r = redis.call('SCAN', cursor, 'MATCH', KEYS[1])
        cursor = r[1]
        count = count + #r[2]
      until cursor == '0'
      return count]]

    -- Users
    local hash = 'msgs:*:' .. our_id
    local r = redis:eval(redis_scan, 1, hash)
    local text = 'Users: ' .. r

    hash = 'chat:*:users'
    r = redis:eval(redis_scan, 1, hash)
    text = text .. '\nChats: ' .. r

    return text

  end

--------------------------------------------------------------------------------

  local function run(msg, matches)
    if is_administrate(msg, msg.to.peer_id) then
      if matches[1]:lower() == 'stats' then
        if not matches[2] then
          if is_chat_msg(msg) then
            return chat_stats(msg, msg.to.peer_id)
          else
            return 'Stats works only on chats'
          end
        end

        if matches[2] == 'bot' then
          if not is_sudo(msg.from.peer_id) then
            return 'Bot stats requires privileged user'
          else
            return bot_stats()
          end
        end

        if matches[2] == 'chat' then
          if not is_sudo(msg.from.peer_id) then
            return 'This command requires privileged user'
          else
            return chat_stats(msg, matches[3])
          end
        end
      end
    end
  end

--------------------------------------------------------------------------------

  return {
    description = 'Plugin to update user stats.',
    usage = {
      '<code>!stats</code>',
      'Returns a list of Username <code>[telegram_id] : msg_num</code>',
      '',
      '<code>!stats chat [chat_id]</code>',
      'Show stats for chat_id',
      '',
      '<code>!stats bot</code>',
      'Shows bot stats (sudo users)'
    },
    patterns = {
      '^!([Ss]tats)$',
      '^!([Ss]tats) (chat) (%d+)',
      '^!([Ss]tats) (bot)'
    },
    run = run,
    pre_process = pre_process
  }

end
