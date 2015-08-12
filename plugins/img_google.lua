do
local mime = require("mime")

local google_config = load_from_file('data/google.lua')
local cache = {}

--[[
local function send_request(url)
  local t = {}
  local options = {
    url = url,
    sink = ltn12.sink.table(t),
    method = "GET"
  }
  local a, code, headers, status = http.request(options)
  return table.concat(t), code, headers, status
end]]--

local function get_google_data(text)
  local url = "http://ajax.googleapis.com/ajax/services/search/images?"
  url = url.."v=1.0&rsz=5"
  url = url.."&q="..URL.escape(text)
  url = url.."&imgsz=small|medium|large"
  if google_config.api_keys then
    local i = math.random(#google_config.api_keys)
    local api_key = google_config.api_keys[i]
    if api_key then
      url = url.."&key="..api_key
    end
  end

  local res, code = http.request(url)
  
  if code ~= 200 then 
    print("HTTP Error code:", code)
    return nil 
  end
  
  local google = json:decode(res)
  return google
end

-- Returns only the useful google data to save on cache
local function simple_google_table(google)
  local new_table = {}
  new_table.responseData = {}
  new_table.responseDetails = google.responseDetails
  new_table.responseStatus = google.responseStatus
  new_table.responseData.results = {}
  local results = google.responseData.results
  for k,result in pairs(results) do
    new_table.responseData.results[k] = {}
    new_table.responseData.results[k].unescapedUrl = result.unescapedUrl
    new_table.responseData.results[k].url = result.url
  end
  return new_table
end

local function save_to_cache(query, data)
  -- Saves result on cache
  if string.len(query) <= 7 then
    local text_b64 = mime.b64(query)
    if not cache[text_b64] then
      local simple_google = simple_google_table(data)
      cache[text_b64] = simple_google
    end
  end
end

local function process_google_data(google, receiver, query)
  if google.responseStatus == 403 then
    local text = 'ERROR: Reached maximum searches per day'
    send_msg(receiver, text, ok_cb, false)

  elseif google.responseStatus == 200 then
    local data = google.responseData

    if not data or not data.results or #data.results == 0 then
      local text = 'Image not found.'
      send_msg(receiver, text, ok_cb, false)
      return false
    end

    -- Random image from table
    local i = math.random(#data.results)
    local url = data.results[i].unescapedUrl or data.results[i].url
    local old_timeout = http.TIMEOUT or 10
    http.TIMEOUT = 5
    send_photo_from_url(receiver, url)
    http.TIMEOUT = old_timeout

    save_to_cache(query, google)
  
  else
    local text = 'ERROR!'
    send_msg(receiver, text, ok_cb, false)
  end
end

function run(msg, matches)
  local receiver = get_receiver(msg)
  local text = matches[1]
  local text_b64 = mime.b64(text)
  local cached = cache[text_b64]
  if cached then
    process_google_data(cached, receiver, text)
  else
    local data = get_google_data(text)    
    process_google_data(data, receiver, text)
  end
end

return {
  description = "Search image with Google API and sends it.", 
  usage = "!img [term]: Random search an image with Google API.",
  patterns = {
    "^!img (.*)$"
  }, 
  run = run
}

end
