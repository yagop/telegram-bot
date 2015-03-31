do

local BASE_URL = 'http://gdata.youtube.com/feeds/api/'

function get_yt_data (yt_code)
  local url = BASE_URL..'/videos/'..yt_code..'?v=2&alt=jsonc'
  local res,code  = http.request(url)
  if code ~= 200 then return "HTTP ERROR" end
  local data = json:decode(res).data
  return data
end

function send_youtube_data(data, receiver)
  local title = data.title
  local description = data.description
  local uploader = data.uploader
  local text = title..' ('..uploader..')\n'..description
  local image_url = data.thumbnail.hqDefault
  local cb_extra = {
    receiver = receiver,
    url = image_url
  }
  send_msg(receiver, text, send_photo_from_url_callback, cb_extra)
end

function run(msg, matches)
  local yt_code = matches[1]
  local data = get_yt_data(yt_code)
  local receiver = get_receiver(msg)
  send_youtube_data(data, receiver)
end

return {
  description = "Sends YouTube info and image.", 
  usage = "",
  patterns = {
    "youtu.be/([_A-Za-z0-9-]+)",
    "youtube.com/watch%?v=([_A-Za-z0-9-]+)",
  },
  run = run 
}

end
