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

-- Removes spaces
function string.trim(s)
  return s:gsub("^%s*(.-)%s*$", "%1")
end

function download_to_file( url , noremove )
  print("url to download: "..url)
  local ltn12 = require "ltn12"
  local respbody = {}
  one, c, h = http.request{url=url, sink=ltn12.sink.table(respbody), redirect=true}
  htype = h["content-type"]

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
    print(file_path.."will be removed in 20 seconds")
    postpone(rmtmp_cb, file_path, 20)
  end

  return file_path
end

-- Callback to remove a file
function rmtmp_cb(file_path, success, result)
   os.remove(file_path)
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
   for v,user in pairs(_config.sudo_users) do 
      if user == msg.from.id then 
         var = true 
      end
   end
   return var
end

-- Returns the name of the sender
function get_name(msg)
   local name = msg.from.first_name
   if name == nil then
      name = msg.from.id
   end
   return name
end

-- Returns at table of lua files inside plugins
function plugins_names( )
  local files = {}
  for k, v in pairs(scandir("plugins")) do
    -- Ends with .lua
    if (v:match(".lua$")) then
      table.insert(files, v)
    end 
  end
  return files
end

-- Function name explains what it does.
function file_exists(name)
  local f = io.open(name,"r")
  if f ~= nil then 
    io.close(f) 
    return true 
  else 
    return false 
  end
end

-- Save into file the data serialized for lua.
function serialize_to_file(data, file)
  file = io.open(file, 'w+')
  local serialized = serpent.block(data, {
    comment = false,
    name = "_"
  })
  file:write(serialized)
  file:close()
end

-- Retruns true if the string is empty
function string:isempty()
  return self == nil or self == ''
end

-- Retruns true if the string is blank
function string:isblank()
  self = self:trim()
  return self:isempty()
end

function string.starts(String, Start)
   return Start == string.sub(String,1,string.len(Start))
end
