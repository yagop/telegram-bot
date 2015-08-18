do
   local google_config = load_from_file('data/google.lua')

   local function httpsRequest(url)
      print(url)
      local res,code  = https.request(url)
      if code ~= 200 then return nil end
      return json:decode(res)
   end

   function get_yt_data (yt_code)
      local url = 'https://www.googleapis.com/youtube/v3/videos?'
      url = url .. 'id=' .. URL.escape(yt_code) .. '&part=snippet'
      if google_config.api_keys then
         local i = math.random(#google_config.api_keys)
         local api_key = google_config.api_keys[i]
         if api_key then
            url = url.."&key="..api_key
         end
      end
      return httpsRequest(url)
   end

   function send_youtube_data(data, receiver)
      local title = data.title
      local description = data.description
      local uploader = data.channelTitle
      local text = title..' ('..uploader..')\n'..description
      local image_url = data.thumbnails.high.url or data.thumbnails.default.url
      local cb_extra = {
         receiver = receiver,
         url = image_url
      }
      send_msg(receiver, text, send_photo_from_url_callback, cb_extra)
   end

   function run(msg, matches)
      local yt_code = matches[1]
      local data = get_yt_data(yt_code)
      if data == nil or #data.items == 0 then
         return "I didn't find info about that video."
      end
      local senddata = data.items[1].snippet
      local receiver = get_receiver(msg)
      send_youtube_data(senddata, receiver)
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
