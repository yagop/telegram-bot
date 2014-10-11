http = require("socket.http")
URL = require("socket.url")
json = (loadfile "./bot/JSON.lua")()

VERSION = 'v0.5'


function on_msg_receive (msg)

  if msg_valid(msg) == false then
    return
  end
  -- Check if command starts with ! eg !echo
  if msg.text:sub(0,1) == '!' then
    do_action(msg)
  else
    if is_image_url(msg.text) then
      send_image_from_url (msg)
    elseif is_youtube_url(msg.text) then
      send_youtube_thumbnail(msg)
    else
      if is_file_url(msg.text) then
        send_file_from_url(msg)
      end
    end
  end

  mark_read(get_receiver(msg), ok_cb, false)
  -- write_log_file(msg)
end


function ok_cb(extra, success, result)
end

function msg_valid(msg)
   if msg.out then
      return false
   end
   if msg.date < now then
     return false
   end
   if msg.text == nil then
      return false
   end
   if msg.unread == 0 then
      return false
   end
end

function send_file_from_url (msg)
  last = string.get_last_word(msg.text)
  file = download_to_file(last)
  send_document(get_receiver(msg), file, ok_cb, false)
end

function send_image_from_url (msg)
  last = string.get_last_word(msg.text)
  file = download_to_file(last)
  send_photo(get_receiver(msg), file, ok_cb, false)
end

function is_image_url(text)
  last = string.get_last_word(text)
  extension = string.get_extension_from_filename(last) -- TODO:  Change it please
  if extension == 'jpg' or extension == 'png' or extension == 'jpeg' then
    return true
  end
  return false
end

function is_youtube_url(text)
  -- http://stackoverflow.com/questions/19377262/regex-for-youtube-url
  if string.match(text, "youtube.com/watch%?v=([A-Za-z0-9-]+)") then
    return true
  end
  if string.match(text, "youtu.be/([A-Za-z0-9-]+)") then
    return true
  end
  return false
end

function send_youtube_thumbnail(msg)
  local yt_normal = string.match(msg.text, "youtube.com/watch%?v=([A-Za-z0-9-]+)")
  if yt_normal then
    yt_code = yt_normal
  end
  yt_short = string.match(msg.text, "youtu.be/([A-Za-z0-9-]+)")
  if yt_short then
    yt_code = yt_short
  end
  yt_thumbnail = "http://img.youtube.com/vi/".. yt_code .."/hqdefault.jpg"
  print (yt_thumbnail)
  file = download_to_file(yt_thumbnail)
  send_photo(get_receiver(msg), file, ok_cb, false)
end

function is_file_url(text)
  last = string.get_last_word(text)
  extension = string.get_extension_from_filename(last)
  if extension == 'gif' then
    return true
  end
  return false
end

-- Where magic happens
function do_action(msg)
   local receiver = get_receiver(msg)

   if string.starts(msg.text, '!sh') then
      text = run_sh(msg)
      send_msg(receiver, text, ok_cb, false)
      return
   end
  
   if string.starts(msg.text, '!uc3m') then
      text = get_fortunes_uc3m()
      send_msg(receiver, text, ok_cb, false)
      return
   end 

   if string.starts(msg.text, '!img') then
      text = msg.text:sub(6,-1)
      url = getGoogleImage(text)
      file_path = download_to_file(url)
      print(file_path)
      send_photo(receiver, file_path, ok_cb, false)
      return
   end

  if string.starts(msg.text, '!rae') then
    text = msg.text:sub(6,-1)
    meaning = getDulcinea(text)
    send_msg(receiver, meaning, ok_cb, false)
  end
  
  if string.starts(msg.text, '!9gag') then
    url, title = get_9GAG()
    file_path = download_to_file(url)
    send_photo(receiver, file_path, ok_cb, false)
    send_msg(receiver, title, ok_cb, false)
    return
  end 

   if string.starts(msg.text, '!fortune') then
      text = run_bash('fortune')
      send_msg(receiver, text, ok_cb, false)
      return
   end 

   if string.starts(msg.text, '!forni') then
      text = msg.text:sub(8,-1)
      send_msg('Fornicio_2.0', text, ok_cb, false)
      return
   end 

   if string.starts(msg.text, '!fwd') then
      fwd_msg (receiver, msg.id, ok_cb, false)
      return
   end 

   if string.starts(msg.text, '!cpu') then
      text = run_bash('uname -snr') .. ' ' .. run_bash('whoami')
      text = text .. '\n' .. run_bash('top -b |head -2')
      send_msg(receiver, text, ok_cb, false)
      return
   end

   if string.starts(msg.text, '!ping') then
      print('receiver: '..receiver)
      send_msg (receiver, 'pong', ok_cb, false)
      return
   end

   if string.starts(msg.text, '!weather') then
      if string.len(msg.text) <= 9 then
         city = 'Madrid,ES'
      else  
         city = msg.text:sub(10,-1)
      end    
      text = get_weather(city)
      send_msg(receiver, text, ok_cb, false)
      return
   end

   if string.starts(msg.text, '!echo') then
      echo = msg.text:sub(7,-1)
      send_msg(receiver, echo, ok_cb, false)
      return
   end

   if string.starts(msg.text, '!eur') then
      local eur = getEURUSD( )
      send_msg(receiver, eur, ok_cb, false)
      return
   end

   if string.starts(msg.text, '!version') then
      text = 'James Bot '.. VERSION .. [[ 
Licencia GNU v2, código disponible en http://git.io/6jdjGg

Al Bot le gusta la gente solidaria. 
Puedes hacer una donación a la ONG que decidas y ayudar a otras personas.]]
      send_msg(receiver, text, ok_cb, false)
      return
   end

   if string.starts(msg.text, '!help') then
      text = [[!help : print this help 
!ping : bot sends pong 
!sh (text) : send commands to bash (only privileged users)
!echo (text) : echo the msg 
!version : version info
!cpu : status (uname + top)
!fwd : forward msg
!forni : send text to group Fornicio
!fortune : print a random adage
!weather [city] : weather in that city (Madrid if not city)
!9gag : send random url image from 9gag
!rae (word): Spanish dictionary
!eur : EURUSD market value
!img (text) : search image with Google API and sends it
!uc3m : fortunes from Universidad Carlos III]]
      send_msg(receiver, text, ok_cb, false)
      return
   end

end

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function load_config()
   local f = assert(io.open('./bot/config.json', "r"))
   local c = f:read "*a"
   local config = json:decode(c)
   if config.torrent_path then 
      print ("!sh command is enabled")
      for v,user in pairs(config.sudo_users) do
         print("Allowed user: " .. user)
      end
   end
   -- print("Torrent path: " .. config.torrent_path)
   f:close()
   return config
end

function is_sudo(msg)
   local var = false
   -- Check users id in config 
   for v,user in pairs(config.sudo_users) do 
      if user == msg.from.id then 
         var = true 
      end
   end
   return var
end

function write_log_file(msg)
  name = get_name(msg)
  ret = name .. ' > ' .. msg.text
  write_to_file(config.log_file, ret)
end

-- Saves a string to file
function write_to_file(filename, value)
  if (value) then
    local file = io.open(filename,"a")
    file:write(value, "\n")
    file:close()
  end
end

function get_name(msg)
   local name = msg.from.first_name
   if name == nil then
      name = msg.from.id
   end
   return name
end

function run_sh(msg)
   name = get_name(msg)
   text = ''
   if config.sh_enabled == false then 
      text = '!sh command is disabled'
   else
      if is_sudo(msg) then
         bash = msg.text:sub(4,-1)
         text = run_bash(bash)
      else
         text = name .. ' you have no power here!'
      end
   end
   return text
end

function run_bash(str)
  local cmd = io.popen(str)
  local result = cmd:read('*all')
  cmd:close()
  return result
end

function get_fortunes_uc3m()
   math.randomseed(os.time())
   local i = math.random(0,178) -- max 178
   local web = "http://www.gul.es/fortunes/f"..i 
   b, c, h = http.request(web)
   return b
end

function getDulcinea( text )
  -- Powered by https://github.com/javierhonduco/dulcinea
  local api = "http://dulcinea.herokuapp.com/api/?query="
  b = http.request(api..text)
  dulcinea = json:decode(b)
  if dulcinea.status == "error" then
    return "Error: " .. dulcinea.message
  end
  while dulcinea.type == "multiple" do
    text = dulcinea.response[1].id
    b = http.request(api..text)
    dulcinea = json:decode(b)
  end
  vardump(dulcinea)
  local text = ""
  local responses = #dulcinea.response
  if (responses > 5) then
    responses = 5
  end
  for i = 1, responses, 1 do 
    text = text .. dulcinea.response[i].word .. "\n"
    local meanings = #dulcinea.response[i].meanings
    if (meanings > 5) then
      meanings = 5
    end
    for j = 1, meanings, 1 do
      local meaning = dulcinea.response[i].meanings[j].meaning 
      text = text .. meaning .. "\n\n"
    end
  end
  return text

end

function getGoogleImage(text)
  text = URL.escape(text)
  for i = 1, 5, 1 do -- Try 5 times
    local api = "https://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=8&q="
    b = http.request(api..text)
    local google = json:decode(b)

    if (google.responseStatus == 200) then -- OK
      math.randomseed(os.time())
      i = math.random(#google.responseData.results) -- Random image from results
      return google.responseData.results[i].url
    end
  end
end

function get_9GAG()
   b = http.request("http://api-9gag.herokuapp.com/")
   local gag = json:decode(b)
   math.randomseed(os.time())
   i = math.random(#gag) -- random max json table size (# is an operator o.O)
   local link_image = gag[i].src
   local title = gag[i].title
   if link_image:sub(0,2) == '//' then
      link_image = msg.text:sub(3,-1)
   end
   return link_image, title
end

function getEURUSD( )
  b = http.request("http://webrates.truefx.com/rates/connect.html?c=EUR/USD&f=csv&s=n")
  local rates = b:split(", ")
  local symbol = rates[1]
  local timestamp = rates[2]
  local sell = rates[3]..rates[4]
  local buy = rates[5]..rates[6]
  return symbol..'\n'..'Buy: '..buy..'\n'..'Sell: '..sell
end


function download_to_file( url )
  print("url a descargar: "..url)
  req, c, h = http.request(url)
  htype = h["content-type"]
  vardump(c)
  print("content-type: "..htype)
  if htype == "image/jpeg" then
    file_name = string.random(5)..".jpg"
    file_path = "/tmp/"..file_name
  else
    if htype == "image/gif" then
      file_name = string.random(5)..".gif"
      file_path = "/tmp/"..file_name
    else
      if htype == "image/png" then
        file_name = string.random(5)..".png"
        file_path = "/tmp/"..file_name
      else
        file_name = url:match("([^/]+)$")
        file_path = "/tmp/"..file_name
      end
    end
  end
  file = io.open(file_path, "w+")
  file:write(req)
  file:close()
  return file_path
end

function get_weather(location)
   b, c, h = http.request("http://api.openweathermap.org/data/2.5/weather?q=" .. location .. "&units=metric")
   weather = json:decode(b)
   local city = weather.name
   local country = weather.sys.country
   temp = 'The temperature in ' .. city .. ' (' .. country .. ')'
   temp = temp .. ' is ' .. weather.main.temp .. '°C'
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

function string.random(length)
   math.randomseed(os.time())
   local str = "";
   for i = 1, length do
      math.random(97, 122)
      str = str..string.char(math.random(97, 122));
   end
   return str;
end

function string.get_extension_from_filename( filename )
  return filename:match( "%.([^%.]+)$" )
end

function string.get_last_word( words )
  local splitted = split_by_space ( words )
  return splitted[#splitted]
end

function split_by_space ( text )
  words = {}
  for word in string.gmatch(text, "[^%s]+") do
     table.insert(words, word) 
  end
  return words
end

function string:split(sep)
        local sep, fields = sep or ":", {}
        local pattern = string.format("([^%s]+)", sep)
        self:gsub(pattern, function(c) fields[#fields+1] = c end)
        return fields
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

-- Start and load values
config = load_config()
our_id = 0
now = os.time()

function get_receiver(msg)
  if msg.to.type == 'user' then
    return 'user#id'..msg.from.id
  end
  if msg.to.type == 'chat' then
    return 'chat#id'..msg.to.id
  end
end


function on_our_id (id)
  our_id = id
end

function on_user_update (user, what)
  --vardump (user)
end

function on_chat_update (chat, what)
  --vardump (chat)
end

function on_secret_chat_update (schat, what)
  --vardump (schat)
end

function on_get_difference_end ()
end

function on_binlog_replay_end ()
  started = 1
end
