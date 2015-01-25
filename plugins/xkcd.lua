
function get_xkcd()
   first_url = http.request("http://xkcd.com/info.0.json")
   local xcomicinfo = json:decode(first_url)  
   math.randomseed(os.time())
   i = math.random(1,xcomicinfo.num) 
   b = http.request("http://xkcd.com/" .. i .. "/info.0.json")
   local comicjson = json:decode(b)
   local link_image = comicjson.img
   c = http.request(link_image)
   local title = comicjson.title
   if link_image:sub(0,2) == '//' then
      link_image = msg.text:sub(3,-1)
   end
   return link_image, title
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
    description = "send random comic image from xkcd", 
    usage = "!xkcd",
    patterns = {"^!xkcd$"}, 
    run = run 
}

