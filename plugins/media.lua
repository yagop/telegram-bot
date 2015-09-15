do

local function run(msg, matches)
  local receiver = get_receiver(msg)
  local url = matches[1]
  local ext = matches[2]

  local file = download_to_file(url)
  local cb_extra = {file_path=file}
  
  local mime_type = mimetype.get_content_type_no_sub(ext)

  if ext == 'gif' then
    print('send_file')
    send_document(receiver, file, rmtmp_cb, cb_extra)

  elseif mime_type == 'text' then
    print('send_document')
    send_document(receiver, file, rmtmp_cb, cb_extra)
  
  elseif mime_type == 'image' then
    print('send_photo')
    send_photo(receiver, file, rmtmp_cb, cb_extra)
  
  elseif mime_type == 'audio' then
    print('send_audio')
    send_audio(receiver, file, rmtmp_cb, cb_extra)

  elseif mime_type == 'video' then
    print('send_video')
    send_video(receiver, file, rmtmp_cb, cb_extra)
  
  else
    print('send_file')
    send_file(receiver, file, rmtmp_cb, cb_extra)
  end
  
end

return {
  description = "When user sends media URL (ends with gif, mp4, pdf, etc.) download and send it to origin.", 
  usage = "When user sends media URL (ends with gif, mp4, pdf, etc.) download and send it to origin.",
  patterns = {
    "(https?://[%w-_%.%?%.:/%+=&]+%.(gif))$",
    "(https?://[%w-_%.%?%.:/%+=&]+%.(mp4))$",
    "(https?://[%w-_%.%?%.:/%+=&]+%.(pdf))$",
    "(https?://[%w-_%.%?%.:/%+=&]+%.(ogg))$",
    "(https?://[%w-_%.%?%.:/%+=&]+%.(zip))$",
    "(https?://[%w-_%.%?%.:/%+=&]+%.(mp3))$",
    "(https?://[%w-_%.%?%.:/%+=&]+%.(rar))$",
    "(https?://[%w-_%.%?%.:/%+=&]+%.(wmv))$",
    "(https?://[%w-_%.%?%.:/%+=&]+%.(doc))$",
    "(https?://[%w-_%.%?%.:/%+=&]+%.(avi))$",
    "(https?://[%w-_%.%?%.:/%+=&]+%.(webp))$"
  }, 
  run = run 
}

end
