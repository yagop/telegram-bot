do
local socket = require("socket")
local cronned = load_from_file('data/isup.lua')

local function save_cron(msg, url, delete)
  local origin = get_receiver(msg)
  if not cronned[origin] then
    cronned[origin] = {}
  end
  if not delete then
    table.insert(cronned[origin], url)
  else
    for k,v in pairs(cronned[origin]) do
      if v == url then
        table.remove(cronned[origin], k)
      end
    end
  end
  serialize_to_file(cronned, 'data/isup.lua')
  return 'Saved!'
end

local function is_up_socket(ip, port)
  print('Connect to', ip, port)
  local c = socket.try(socket.tcp())
  c:settimeout(3)
  local conn = c:connect(ip, port)
  if not conn then
    return false
  else
    c:close()
    return true
  end
end

local function is_up_http(url)
  -- Parse URL from input, default to http
  local parsed_url = URL.parse(url,  { scheme = 'http', authority = '' })
  -- Fix URLs without subdomain not parsed properly
  if not parsed_url.host and parsed_url.path then
    parsed_url.host = parsed_url.path
    parsed_url.path = ""
  end
  -- Re-build URL
  local url = URL.build(parsed_url)

  local protocols = {
    ["https"] = https,
    ["http"] = http
  }
  local options =  {
    url = url,
    redirect = false,
    method = "GET"
  }
  local response = { protocols[parsed_url.scheme].request(options) }
  local code = tonumber(response[2])
  if code == nil or code >= 400 then
    return false
  end
  return true
end

local function isup(url)
  local pattern = '^(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?):?(%d?%d?%d?%d?%d?)$'
  local ip,port = string.match(url, pattern)
  local result = nil

  -- !isup 8.8.8.8:53
  if ip then
    port = port or '80'
    result = is_up_socket(ip, port)
  else
    result = is_up_http(url)
  end

  return result
end

local function cron()
  for chan, urls in pairs(cronned) do
    for k,url in pairs(urls) do
      print('Checking', url)
      if not isup(url) then
        local text = url..' looks DOWN from here. 😱'
        send_msg(chan, text, ok_cb, false)
      end
    end
  end
end

local function run(msg, matches)
  if matches[1] == 'cron delete' then
    if not is_sudo(msg) then 
      return 'This command requires privileged user'
    end
    return save_cron(msg, matches[2], true)

  elseif matches[1] == 'cron' then
    if not is_sudo(msg) then 
      return 'This command requires privileged user'
    end
    return save_cron(msg, matches[2])

  elseif isup(matches[1]) then
    return matches[1]..' looks UP from here. 😃'
  else
    return matches[1]..' looks DOWN from here. 😱'
  end
end

return {
  description = "Check if a website or server is up.",
  usage = {
    "!isup [host]: Performs a HTTP request or Socket (ip:port) connection",
    "!isup cron [host]: Every 5mins check if host is up. (Requires privileged user)",
    "!isup cron delete [host]: Disable checking that host."
  },
  patterns = {
    "^!isup (cron delete) (.*)$",
    "^!isup (cron) (.*)$",
    "^!isup (.*)$",
    "^!ping (.*)$",
    "^!ping (cron delete) (.*)$",
    "^!ping (cron) (.*)$"
  },
  run = run,
  cron = cron
}

end
