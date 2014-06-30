our_id = 0

function on_msg_receive (msg)
   -- vardump(msg)
   if msg.out then
      return
   end
   if msg.text == nil then
      return
   end
   if msg.unread == 0 then
      return
   end
   -- Check if command starts with ! eg !echo
   if msg.text:sub(0,1) == '!' then
      msg.text = msg.text:sub(2,-1)
      do_action(msg)
   end
end

function do_action(msg)
   receiver = get_receiver(msg)
   if string.starts(msg.text, 'forni') then
      text = msg.text:sub(7,-1)
      send_msg('Fornicio_2.0', text)
   end  
   if string.starts(msg.text, 'fwd') then
      fwd_msg (receiver, msg.id)
   end  
   if string.starts(msg.text, 'cpu') then
      text = run_bash('uname -snr')
      text = text .. '\n' .. run_bash('top -b |head -2')
      send_msg(receiver, text)
   end
   if string.starts(msg.text, 'ping') then
      send_msg(receiver, "pong")
   end
   if string.starts(msg.text, 'echo') then
      -- Removes echo from the string
      echo = msg.text:sub(6,-1)
      send_msg(receiver, echo)
   end
   if string.starts(msg.text, 'version') then
      text = 'v0.0.2 aka Study\n'
      text = text .. 'Host user: ' .. run_bash('whoami')
      send_msg(receiver, text)
   end
   if string.starts(msg.text, 'help') then
      text = [[ !help : print this help 
!ping : bot sends pong 
!echo <text> : echoes the msg 
!version : version info
!cpu : Status (uname + top)
!fwd : Forward msg
!forni : Send text to group Fornicio]]
      send_msg(receiver, text)
   end
end

function get_receiver(msg)
   if msg.to.type == 'user' then
      return msg.from.print_name
   end
   if msg.to.type == 'chat' then
      return msg.to.print_name
   end   
end


function on_our_id (id)
   our_id = id
end

function on_secret_chat_created (peer)
end

function on_user_update (user)
end

function on_chat_update (user)
end

function on_get_difference_end ()
end

function on_binlog_replay_end ()
end

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function run_bash(str)
  local cmd = io.popen(str)
  local result = cmd:read('*all')
  cmd:close()
  return result
end

function vardump(value, depth, key)
  local linePrefix = ""
  local spaces = ""
  
  if key ~= nil then
    linePrefix = "["..key.."] = "
  end
  
  if depth == nil then
    depth = 0
  else
    depth = depth + 1
    for i=1, depth do spaces = spaces .. "  " end
  end
  
  if type(value) == 'table' then
    mTable = getmetatable(value)
    if mTable == nil then
      print(spaces ..linePrefix.."(table) ")
    else
      print(spaces .."(metatable) ")
        value = mTable
    end		
    for tableKey, tableValue in pairs(value) do
      vardump(tableValue, depth, tableKey)
    end
  elseif type(value)	== 'function' or 
      type(value)	== 'thread' or 
      type(value)	== 'userdata' or
      value		== nil
  then
    print(spaces..tostring(value))
  else
    print(spaces..linePrefix.."("..type(value)..") "..tostring(value))
  end
end
