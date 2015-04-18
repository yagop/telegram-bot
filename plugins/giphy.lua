-- Idea by https://github.com/asdofindia/telegram-bot/
-- See http://api.giphy.com/

do

local BASE_URL = 'http://api.giphy.com/v1'
local API_KEY = 'dc6zaTOxFJmzC' -- public beta key

local function get_image(response)
  local images = json:decode(response).data
  if #images == 0 then return nil end -- No images
  local i = math.random(#images)
  local image =  images[i] -- A random one

  if image.images.downsized then
    return image.images.downsized.url
  end

  if image.images.original then
    return image.original.url
  end

  return nil
end

local function get_random_top()
  local url = BASE_URL.."/gifs/trending?api_key="..API_KEY
  local response, code = http.request(url)
  if code ~= 200 then return nil end
  return get_image(response)
end

local function search(text)
  text = URL.escape(text)
  local url = BASE_URL.."/gifs/search?q="..text.."&api_key="..API_KEY
  local response, code = http.request(url)
  if code ~= 200 then return nil end
  return get_image(response)
end

local function send_gif(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local gif_url = cb_extra.gif_url
  send_document_from_url(receiver, gif_url)
end

local function run(msg, matches)
  local gif_url = nil
  
  -- If no search data, a random trending GIF will be sended
  if matches[1] == "!gif" or matches[1] == "!giphy" then
    gif_url = get_random_top()
  else
    gif_url = search(matches[1])
  end

  if not gif_url then 
    return "Error: GIF not found"
  end

  local receiver = get_receiver(msg)
  print("GIF URL"..gif_url)
  local text = 'Preparing to make you laugh'
  local cb_extra = {
    gif_url = gif_url,
    receiver = receiver
  }
  send_msg(receiver, text, send_gif, cb_extra)
end

return {
  description = "GIFs from telegram with Giphy API",
  usage = {
    "!gif (term): Search and sends GIF from Giphy. If no param, sends a trending GIF.",
    "!giphy (term): Search and sends GIF from Giphy. If no param, sends a trending GIF."
    },
  patterns = {
    "^!gif$",
    "^!gif (.*)",
    "^!giphy (.*)",
    "^!giphy$"
  },
  run = run
}

end