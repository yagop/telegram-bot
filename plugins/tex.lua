do

local function send_title(cb_extra, success, result)
  if success then
    send_msg(cb_extra[1], cb_extra[2], ok_cb, false)
  end
end

local function run(msg, matches)
  local eq = URL.escape(matches[1])

  local url = "http://latex.codecogs.com/png.download?"
    .."\\dpi{300}%20\\LARGE%20"..eq

  local receiver = get_receiver(msg)
  local title = "Edit LaTeX on www.codecogs.com/eqnedit.php?latex="..eq
  send_photo_from_url(receiver, url, send_title, {receiver, title})
end

return {
  description = "Convert LaTeX equation to image",
  usage = {
    "!tex [equation]: Convert LaTeX equation to image"
  },
  patterns = {
    "^!tex (.+)$"
  },
  run = run
}

end

