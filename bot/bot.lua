  http = require("socket.http")
  URL = require("socket.url")
  json = (loadfile "./bot/JSON.lua")()
--  lrexlib = require("rex_pcre")

  VERSION = 'v0.6'

  plugins = {}
  
  -- taken from http://stackoverflow.com/a/11130774/3163199
  function scandir(directory)
    local i, t, popen = 0, {}, io.popen
    for filename in popen('ls -a "'..directory..'"'):lines() do
        i = i + 1
        t[i] = filename
    end
    return t
  end

  -- load all plugins in the plugins/ directory
  for k, v in pairs(scandir("plugins")) do 
    if not (v:sub(0, 1) == ".") then
        print("Loading plugin", v)
        t = loadfile("plugins/" .. v)()
        table.insert(plugins, t)
    end 
  end

  function on_msg_receive (msg)
    if msg_valid(msg) == false then
      return
    end

    do_action(msg)

    mark_read(get_receiver(msg), ok_cb, false)
    -- write_log_file(msg)
  end

  function ok_cb(extra, success, result)
  end

  function msg_valid(msg)
    if msg.text == nil then
      return false
    end
    if msg.from.id == our_id then
      return true
    end
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

  -- Where magic happens
  function do_action(msg)
    local receiver = get_receiver(msg)
    local text = msg.text
    print("Received msg", text)
    for name, desc in pairs(plugins) do
      print("Trying module", name)
      for k, pattern in pairs(desc.patterns) do
        print("Trying", text, "against", pattern)
        matches = { string.match(text, pattern) }
        if matches[1] then
          print("  matches!")
          result = desc.run(msg, matches)
          print("  should return", result)
          if (result) then
            send_msg(receiver, result, ok_cb, false)
          end
        end
      end
    end
  end

  -- function do_action(msg)
  --    local receiver = get_receiver(msg)

  --    if string.starts(msg.text, '!sh') then
  --       text = run_sh(msg)
  --       send_msg(receiver, text, ok_cb, false)
  --       return
  --    end
  --   
  --    if string.starts(msg.text, '!fortune') then
  --       text = run_bash('fortune')
  --       send_msg(receiver, text, ok_cb, false)
  --       return
  --    end 

  --    if string.starts(msg.text, '!forni') then
  --       text = msg.text:sub(8,-1)
  --       send_msg('Fornicio_2.0', text, ok_cb, false)
  --       return
  --    end 

  --    if string.starts(msg.text, '!fwd') then
  --       fwd_msg (receiver, msg.id, ok_cb, false)
  --       return
  --    end 

  --    if string.starts(msg.text, '!cpu') then
  --       text = run_bash('uname -snr') .. ' ' .. run_bash('whoami')
  --       text = text .. '\n' .. run_bash('top -b |head -2')
  --       send_msg(receiver, text, ok_cb, false)
  --       return
  --    end

  -- end

  function load_config()
     local f = assert(io.open('./bot/config.json', "r"))
     local c = f:read "*a"
     local config = json:decode(c)
     if config.sh_enabled then 
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
