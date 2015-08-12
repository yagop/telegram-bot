--[[
* qr plugin uses:
* - http://goqr.me/api/doc/create-qr-code/
* psykomantis
]]

local function get_hex(str)
  local colors = {
    red = "f00",
    blue = "00f",
    green = "0f0",
    yellow = "ff0",
    purple = "f0f",
    white = "fff",
    black = "000",
    gray = "ccc"
  }

  for color, value in pairs(colors) do
    if color == str then
      return value
    end
  end

  return str
end

local function qr(receiver, text, color, bgcolor)

  local url = "http://api.qrserver.com/v1/create-qr-code/?"
    .."size=600x600"  --fixed size otherways it's low detailed
    .."&data="..URL.escape(text:trim())

  if color then
    url = url.."&color="..get_hex(color)
  end
  if bgcolor then
    url = url.."&bgcolor="..get_hex(bgcolor)
  end

  local response, code, headers = http.request(url)

  if code ~= 200 then
    return "Oops! Error: " .. code
  end

  if #response > 0 then
	  send_photo_from_url(receiver, url)
	return

  end
  return "Oops! Something strange happened :("
end

local function run(msg, matches)
  local receiver = get_receiver(msg)

  local text = matches[1]
  local color
  local back

  if #matches > 1 then
    text = matches[3]
    color = matches[2]
    back = matches[1]
  end

  return qr(receiver, text, color, back)
end

return {
  description = {"qr code plugin for telegram, given a text it returns the qr code"},
  usage = {
    "!qr [text]",
    '!qr "[background color]" "[data color]" [text]\n'
      .."Color through text: red|green|blue|purple|black|white|gray\n"
      .."Colors through hex notation: (\"a56729\" is brown)\n"
      .."Or colors through decimals: (\"255-192-203\" is pink)"
  },
  patterns = {
    '^!qr "(%w+)" "(%w+)" (.+)$',
    "^!qr (.+)$"
  },
  run = run
}