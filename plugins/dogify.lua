local function run(msg, matches)
   local base = "http://dogr.io/"
   local path = string.gsub(matches[1], " ", "%%20")
   local url = base .. path .. '.png?split=false&.png'
   local urlm = "https?://[%%%w-_%.%?%.:/%+=&]+"

   if string.match(url, urlm) == url then
      local receiver = get_receiver(msg)
      send_photo_from_url(receiver, url)
   else
      print("Can't build a good URL with parameter " .. matches[1])
   end
end

return {
   description = "Create a doge image with you words",
   usage = {
      "!dogify (your/words/with/slashes): Create a doge with the image and words"
   },
   patterns = {
      "^!dogify (.+)$",
   },
   run = run
}
