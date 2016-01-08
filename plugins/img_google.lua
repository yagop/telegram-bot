do
local mime = require("mime")

local google_config = load_from_file('data/google.lua')
local cache = {}


local function get_google_data(text)
  local url = "https://www.googleapis.com/customsearch/v1?imgSize=large&num=10&searchType=image"
  url = url.."&key="..google_config.api_key.."&cx="..google_config.cse_cx
  url = url.."&q="..URL.escape(text)

  local res, code = https.request(url)
  
  if code ~= 200 then 
    print("HTTP Error code:", code)
    return nil 
  end
  
  local google = json:decode(res)
  return google
end


-- Returns only the useful google data to save on cache
local function simple_google_table(data)
  local new_table = {}
  new_table.items = {}
  for k,result in pairs(data.items) do
    new_table.items[k] = {}
    new_table.items[k].link = result.link
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


local function process_google_data(data, receiver, query)
  if not data or not data.items or #data.items == 0 then
    local text = 'No image found.'
    send_msg(receiver, text, ok_cb, false)
    return false
  end

  -- Random image from table
  local i = math.random(#data.items)
  local url = data.items[i].link
  local old_timeout = http.TIMEOUT or 10
  http.TIMEOUT = 5
  send_photo_from_url(receiver, url)
  http.TIMEOUT = old_timeout

  save_to_cache(query, data)
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
