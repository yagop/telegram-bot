function get_receiver(msg)
  if msg.to.type == 'user' then
    return 'user#id'..msg.from.id
  end
  if msg.to.type == 'chat' then
    return 'chat#id'..msg.to.id
  end
end

function is_chat_msg( msg )
  if msg.to.type == 'chat' then
    return true
  end
  return false
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

function string:split(sep)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  self:gsub(pattern, function(c) fields[#fields+1] = c end)
  return fields
end

function download_to_file( url , noremove )
  print("url to download: "..url)
  local ltn12 = require "ltn12"
  local respbody = {}
  one, c, h = http.request{url=url, sink=ltn12.sink.table(respbody), redirect=true}
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
  file:write(table.concat(respbody))
  file:close()

  if noremove == nil then
     postpone(rmtmp_cb, file_path, config.rmtmp_delay)
  end

  return file_path
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

-- taken from http://stackoverflow.com/a/11130774/3163199
function scandir(directory)
  local i, t, popen = 0, {}, io.popen
  for filename in popen('ls -a "'..directory..'"'):lines() do
      i = i + 1
      t[i] = filename
  end
  return t
end

-- http://www.lua.org/manual/5.2/manual.html#pdf-io.popen
function run_command(str)
  local cmd = io.popen(str)
  local result = cmd:read('*all')
  cmd:close()
  return result
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

function get_name(msg)
   local name = msg.from.first_name
   if name == nil then
      name = msg.from.id
   end
   return name
end

clock = os.clock
function sleep(n)  -- seconds
  local t0 = clock()
  while clock() - t0 <= n do end
end
