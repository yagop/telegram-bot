do

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
  return searchYoutubeVideo(text)
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
