-- Based on plugin Webshot
local helpers = require "OAuth.helpers"

local base = 'https://screenshotmachine.com/'
local url = base .. 'processor.php'

local function get_webshot_url(param)
   local response_body = {}
   local request_constructor = {
      url = url,
      method = "GET",
      sink = ltn12.sink.table(response_body),
      headers = {
         referer = base,
         dnt = "1",
         origin = base,
         ["User-Agent"] = "Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.101 Safari/537.36"
      },
      redirect = false
   }

   local arguments = {
      urlparam = param,
      size = "FULL"
   }

   request_constructor.url = url .. "?" .. helpers.url_encode_arguments(arguments)

   local ok, response_code, response_headers, response_status_line = https.request(request_constructor)
   if not ok or response_code ~= 200 then
      return nil
   end

   local response = table.concat(response_body)
   return string.match(response, "href='(.-)'")
end

local function run(msg, matches)
   
   if matches[1] == '!code' then
      return "!code [language] [code here]: Send the code in using highlighted. \nList of language supported: http://pastebin.com/HiRrhzUm"
   end
   
   local highlighter = 'http://markup.su/api/highlighter' 
   highlighter = highlighter .. '?language=' .. URL.escape(matches[1]) 
   highlighter = highlighter .. '&theme=Sunburst&source=' .. URL.escape(matches[2]:gsub('—', '--'))
   
   local find = get_webshot_url(highlighter)
   if find then
      local imgurl = base .. find
      local receiver = get_receiver(msg)
      send_photo_from_url(receiver, imgurl)
   end
end


return {
   description = "Send the code in using highlighted.",
   usage = {
      "!code [language] [code here]: Send the code in using highlighted. \nList of language supported: http://pastebin.com/HiRrhzUm"
   },
   patterns = {
      '^!code "(.+)" (.+)$',
      '^!code$'
   },
   run = run
}
