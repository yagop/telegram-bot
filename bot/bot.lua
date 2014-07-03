http = require("socket.http")
json = (loadfile "./bot/JSON.lua")()

our_id = 0
now = os.time()
VERSION = 'v0.0.5'

function on_msg_receive (msg)
   -- vardump(msg)
   if msg.out then
      return
   end
   if msg.date < now then
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
   mark_read(get_receiver(msg))
end

-- Where magic happens
function do_action(msg)
   receiver = get_receiver(msg)
   local name = msg.from.first_name
   if name == nil then
      name = 'Noob '
   end
   if string.starts(msg.text, 'sh') then
      bash = msg.text:sub(4,-1)
      if is_sudo(msg) then
         text = run_bash(bash)
      else
         text = name .. ' you have no power here!'
      end
      send_msg(receiver, text)
   end   
   if string.starts(msg.text, 'uc3m') then
      text = get_fortunes_uc3m()
      send_msg(receiver, text)
   end 
   if string.starts(msg.text, '9gag') then
      text = get_infiniGAG()
      send_msg(receiver, text)
   end  
   if string.starts(msg.text, 'fortune') then
      text = run_bash('fortune')
      send_msg(receiver, text)
   end 
   if string.starts(msg.text, 'forni') then
      text = msg.text:sub(7,-1)
      send_msg('Fornicio_2.0', text)
   end  
   if string.starts(msg.text, 'fwd') then
      fwd_msg (receiver, msg.id)
   end  
   if string.starts(msg.text, 'cpu') then
      text = run_bash('uname -snr') .. ' ' .. run_bash('whoami')
      text = text .. '\n' .. run_bash('top -b |head -2')
      send_msg(receiver, text)
   end
   if string.starts(msg.text, 'ping') then
      send_msg(receiver, "pong")
   end
   if string.starts(msg.text, 'weather') then
      text = get_weather('Madrid,ES')
      send_msg(receiver, text)
   end
   if string.starts(msg.text, 'echo') then
      -- Removes echo from the string
      echo = msg.text:sub(6,-1)
      send_msg(receiver, echo)
   end
   if string.starts(msg.text, 'version') then
      text = 'James Bot '.. VERSION
      send_msg(receiver, text)
   end
   if string.starts(msg.text, 'help') then
      text = [[!help : print this help 
!ping : bot sends pong 
!echo (text) : echo the msg 
!version : version info
!cpu : status (uname + top)
!fwd : forward msg
!forni : send text to group Fornicio
!fortune : print a random adage
!weather : weather in Madrid
!9gag : send random url image from 9gag]]
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

function is_sudo(msg)
   print('from: '.. msg.from.id)
   if msg.from.id == 11696011 then
      print('is sudo')
      return true
   else
      print('is a noob')
      return false
   end
end

function run_bash(str)
  local cmd = io.popen(str)
  local result = cmd:read('*all')
  cmd:close()
  return result
end

function readAll(file)
    local f = io.open(file, "rb")
    local content = f:read("*all")
    f:close()
    return content
end

function get_fortunes_uc3m()
   i = math.random(0,178) -- max 178 
   b, c, h = http.request("http://www.gul.es/fortunes/f"..i)
   return b
end

function get_infiniGAG()
   b, c, h = http.request("http://infinigag-us.aws.af.cm")
   local gag = json:decode(b)
   -- for key,value in pairs(gag.data) do print(key,value) end
   i = math.random(table.getn(gag.data)) -- random
   local link_image = gag.data[i].images.normal
   return link_image
end


function download_to_file(source, filePath)
   local oFile = io.open(filePath, "w")
   local save = ltn12.sink.file(oFile)
   http.request{url = addr, sink = save } 
end

function get_weather(location)
   b, c, h = http.request("http://api.openweathermap.org/data/2.5/weather?q=" .. location .. "&units=metric")
   weather = json:decode(b)
   temp = 'The temperature in ' .. weather.name .. ' is ' .. weather.main.temp .. '°C'
   conditions = 'Current conditions are: ' .. weather.weather[1].description
   if weather.weather[1].main == 'Clear' then
	  conditions = conditions .. ' ☀'
   elseif weather.weather[1].main == 'Clouds' then
	  conditions = conditions .. ' ☁☁'
   elseif weather.weather[1].main == 'Rain' then
	  conditions = conditions .. ' ☔'
   elseif weather.weather[1].main == 'Thunderstorm' then
	  conditions = conditions .. ' ☔☔☔☔'
   end
   return temp .. '\n' .. conditions
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
