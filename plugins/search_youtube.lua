do

local function get_yt_data (yt_code)
  local base_url = 'http://gdata.youtube.com/feeds/api/'
  local url = base_url..'/videos/'..yt_code..'?v=2&alt=jsonc'
  local res,code  = http.request(url)
  if code ~= 200 then return "HTTP ERROR" end
  local data = json:decode(res).data
  return data
end

local function format_youtube_data(data, link)
  local title = data.title
  local uploader = data.uploader
  local text = title..' ('..uploader..')'..'\n\nLink:' .. link
  return text
end

local function httpRequest(url)
  local res,code  = http.request(url)
  if code ~= 200 then return nil end
  return json:decode(res)
end

local function searchYoutubeVideo(text)
  local base_url = 'http://gdata.youtube.com/feeds/api/'
  local data = httpRequest(base_url..'videos?max-results=1&alt=json&q='..URL.escape(text))
  if not data then
    print("HTTP Error")
    return nil
  elseif not data.feed.entry then
    return "YouTube video not found!"
  end
  return data.feed.entry[1].link[1].href
end

local function run(msg, matches)
  local text = matches[1]
  local link = searchYoutubeVideo(text)
  local yt_code = link:match("?v=([_A-Za-z0-9-]+)")
  local data = get_yt_data(yt_code)
  return format_youtube_data(data, link)
end

return {
  description = "Search video on youtube and send it.",
  usage = "!youtube [term]: Search for a youtube video and send it.",
  patterns = {
    "^!youtube (.*)"
  },
  run = run
}

end
