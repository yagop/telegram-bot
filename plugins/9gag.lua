
function get_9GAG()
   b = http.request("http://api-9gag.herokuapp.com/")
   local gag = json:decode(b)
   math.randomseed(os.time())
   i = math.random(#gag) -- random max json table size (# is an operator o.O)
   local link_image = gag[i].src
   local title = gag[i].title
   if link_image:sub(0,2) == '//' then
      link_image = msg.text:sub(3,-1)
   end
   return link_image, title
end

function run(msg, matches)
  local receiver = get_receiver(msg)
  url, title = get_9GAG()
  file_path = download_to_file(url)
  send_photo(receiver, file_path, ok_cb, false)
  return title
end

return {
    description = "send random image from 9gag", 
    usage = "!9gag",
    patterns = {"^!9gag$"}, 
    run = run 
}

