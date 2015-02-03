function get_xkcd()
  -- Get the latest num
  local res,code  = https.request("http://xkcd.com/info.0.json")
  if code ~= 200 then return "HTTP ERROR" end
  local data = json:decode(res)
  math.randomseed(os.time())
  i = math.random(1, data.num) -- Latest
  local res,code  = http.request("http://xkcd.com/"..i.."/info.0.json")
  if code ~= 200 then return "HTTP ERROR" end
  local data = json:decode(res)
  local link_image = data.img
  if link_image:sub(0,2) == '//' then
    link_image = msg.text:sub(3,-1)
  end
  return link_image, data.title
end

function send_title(cb_extra, success, result)
  if success then
    send_msg(cb_extra[1], cb_extra[2], ok_cb, false)
  end
end

function run(msg, matches)
  local receiver = get_receiver(msg)
  url, title = get_xkcd()
  file_path = download_to_file(url)
  send_photo(receiver, file_path, send_title, {receiver, title})
  return false
end

return {
    description = "Send random comic image from xkcd", 
    usage = "!xkcd",
    patterns = {"^!xkcd$","^.xkcd$"}, 
    run = run 
}
