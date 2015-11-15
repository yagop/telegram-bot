local NUM_MSG_MAX = 5 -- Max number of messages per TIME_CHECK seconds
local TIME_CHECK = 5

local function kick_user(user_id, chat_id)
  local chat = 'chat#id'..chat_id
  local user = 'user#id'..user_id
  chat_del_user(chat, user, function (data, success, result)
    if success ~= 1 then
      local text = 'I can\'t kick '..data.user..' but should be kicked'
      send_msg(data.chat, '', ok_cb, nil)
    end
  end, {chat=chat, user=user})
end

local function run (msg, matches)
  if msg.to.type ~= 'chat' then
    return 'Anti-flood works only on channels'
  else
    local chat = msg.to.id
    local hash = 'anti-flood:enabled:'..chat
    if matches[1] == 'enable' then
      redis:set(hash, true)
      return 'Anti-flood enabled on chat'
    end
    if matches[1] == 'disable' then
      redis:del(hash)
      return 'Anti-flood disabled on chat'
    end
  end
end

local function pre_process (msg)
  -- Ignore service msg
  if msg.service then
    print('Service message')
    return msg
  end

  local hash_enable = 'anti-flood:enabled:'..msg.to.id
  local enabled = redis:get(hash_enable)

  if enabled then
    print('anti-flood enabled')
    -- Check flood
    if msg.from.type == 'user' then
      -- Increase the number of messages from the user on the chat
      local hash = 'anti-flood:'..msg.from.id..':'..msg.to.id..':msg-num'
      local msgs = tonumber(redis:get(hash) or 0)
      if msgs > NUM_MSG_MAX then
        local receiver = get_receiver(msg)
        local user = msg.from.id
        local text = 'User '..user..' is flooding'
        local chat = msg.to.id

        send_msg(receiver, text, ok_cb, nil)
        if msg.to.type ~= 'chat' then
          print("Flood in not a chat group!")
        elseif user == tostring(our_id) then
          print('I won\'t kick myself')
        elseif is_sudo(msg) then
          print('I won\'t kick an admin!')
        else
          -- Ban user
          -- TODO: Check on this plugin bans
          local bhash = 'banned:'..msg.to.id..':'..msg.from.id
          redis:set(bhash, true)
          kick_user(user, chat)
        end
        msg = nil
      end
      redis:setex(hash, TIME_CHECK, msgs+1)
    end
  end
  return msg
end

return {
  description = 'Plugin to kick flooders from group.',
  usage = {},
  patterns = {
    '^!antiflood (enable)$',
    '^!antiflood (disable)$'
  },
  run = run,
  privileged = true,
  pre_process = pre_process
}
