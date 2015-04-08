do

function run(msg, matches)
  local file = download_to_file(matches[1])
  send_document(get_receiver(msg), file, ok_cb, false)
end

return {
  description = "When user sends media URL (ends with gif, mp4, pdf, etc.) download and send it to origin.", 
  usage = "",
  patterns = {
    "(https?://[%w-_%.%?%.:/%+=&]+%.gif)$",
    "(https?://[%w-_%.%?%.:/%+=&]+%.mp4)$",
    "(https?://[%w-_%.%?%.:/%+=&]+%.pdf)$",
    "(https?://[%w-_%.%?%.:/%+=&]+%.ogg)$",
    "(https?://[%w-_%.%?%.:/%+=&]+%.zip)$",
    "(https?://[%w-_%.%?%.:/%+=&]+%.mp3)$",
    "(https?://[%w-_%.%?%.:/%+=&]+%.rar)$",
    "(https?://[%w-_%.%?%.:/%+=&]+%.wmv)$",
    "(https?://[%w-_%.%?%.:/%+=&]+%.doc)$",
    "(https?://[%w-_%.%?%.:/%+=&]+%.avi)$"
  }, 
  run = run 
}

end
