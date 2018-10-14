--[[

Save message as json format to a log file.
Remove phone number, in case if there is phone contact in bots account.
Basically, it's just dumping the message into a file. So, don't be surprised
if the log file size is big.

--]]

do

  local function pre_process(msg)
    local gid = tonumber(msg.to.peer_id)

    if _config.administration[gid] and is_chat_msg(msg) then
      local message = serpent.dump(msg, {comment=false})
      local message = message:match('do local _=(.*);return _;end')
      local message = message:gsub('phone="%d+"', '')
      local logfile = io.open('data/' .. gid .. '/' .. gid .. '.log', 'a')
      logfile:write(message .. '\n')
      logfile:close()
    end

    return msg
  end

  local function run(msg, matches)
    local uid = msg.from.peer_id
    local loggid = msg.to.peer_id
    local receiver = get_receiver(msg)

    if matches[2] and matches[2]:match('^%d+$') then
      loggid = matches[2]
    end

    if is_owner(msg, loggid, uid) then
      if matches[1] == 'get' then
        send_document(receiver, './data/' .. loggid .. '/' .. loggid .. '.log', ok_cb, false)
      elseif matches[1] == 'pm' then
        send_document('user#id' .. uid, './data/' .. loggid .. '/' .. loggid .. '.log', ok_cb, false)
      end
    else
      reply_msg(msg.id, 'You have no privilege to get ' .. loggid .. ' log.', ok_cb, true)
    end
  end

--------------------------------------------------------------------------------

  return {
    description = 'Logging group messages.',
    usage = {
      sudo = {
        '<code>!log get [chat_id]</code>',
        'Send <code>chat_id</code> chat log.',
        '',
        '<code>!log pm [chat_id]</code>',
        'Send <code>chat_id</code> chat log to private message'
      },
      owner = {
        '<code>!log get</code>',
        'Send chat log to its chat group',
        '',
        '<code>!log pm</code>',
        'Send chat log to private message'
      },
    },
    patterns = {
      '^!log (%a+)$',
      '^!log (%a+) (%d+)$'
    },
    run = run,
    pre_process = pre_process,
  }

end
