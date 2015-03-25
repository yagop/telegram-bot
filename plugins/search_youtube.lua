
do

local BASE_URL = 'http://gdata.youtube.com/feeds/api/'

function get_yt_data (yt_code)
  local url = BASE_URL..'/videos/'..yt_code..'?v=2&alt=jsonc'
  local res,code  = http.request(url)
  if code ~= 200 then return "HTTP ERROR" end
  local data = json:decode(res).data
  return data
end

function send_youtube_data(data, receiver, link)
  local title = data.title
  local description = data.description
  local uploader = data.uploader
  local text = title..' ('..uploader..')\n'..description..'\n\nLink:' .. link
  local image_url = data.thumbnail.hqDefault
  local cb_extra = {receiver=receiver, url=image_url}
  send_msg(receiver, text, send_photo_from_url_callback, cb_extra)
end

function searchYoutubeVideo(text)
  local data = httpRequest('http://gdata.youtube.com/feeds/api/videos?max-results=1&alt=json&q=' .. URL.escape(text))
  if not data then
    print("HTTP Error")
    return nil
  elseif not data.feed.entry then
    return "YouTube video not found!"
  end
  return data.feed.entry[1].link[1].href
end

function httpRequest(url)
  local res,code  = http.request(url)
  if code ~= 200 then return nil end
  return json:decode(res)
end

function run(msg, matches)
  local text = msg.text:sub(string.len(matches[1]) + 1,-1)
  local link = searchYoutubeVideo(text)
  local yt_code = link:match("?v=([_A-Za-z0-9-]+)")
  local data = get_yt_data(yt_code)
  local receiver = get_receiver(msg)
  send_youtube_data(data, receiver, link)
end

return {
  description = "Search video on youtube and send it.",
  usage = "!youtube [term]: Search for a youtube video and send it.",
  patterns = {
    "^!youtube"
  },
  run = run
}

end
