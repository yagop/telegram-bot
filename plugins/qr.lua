--[[
* qr plugin uses:
* - http://goqr.me/api/doc/create-qr-code/
* psykomantis
]]

function url_encode(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w %-%_%.%~])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end
  return str
end


function get_hex(str)
  if(string.match(str,"(red)") == "red") then
    return "f00"
  elseif(string.match(str,"(blue)") == "blue") then
    return "00f"
  elseif(string.match(str,"(green)") == "green") then
    return "0f0"
  elseif(string.match(str,"(yellow)") == "yellow") then
    return "ff0"
  elseif(string.match(str,"(purple)") == "purple") then
    return "f0f"
  elseif(string.match(str,"(white)") == "white") then
    return "fff"
  elseif(string.match(str,"(black)") == "black") then
    return "000"
  elseif(string.match(str,"(gray)") == "gray") then
    return "ccc"
  end

  return str
end



do

local function qr(msg, query)

  local receiver = get_receiver(msg)

  local http = require("socket.http")
  local url = "http://api.qrserver.com/v1/create-qr-code/?" .. query .. "&size=600x600"  --fixed size otherways it's low detailed
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

  local query = ""

  if(#matches == 3) then

    local bgcolor = get_hex(matches[1])
    local color = get_hex(matches[2])
    local data = url_encode(matches[3]:trim())

    query = "data=" .. data .. "&color=" .. color .. "&bgcolor=" .. bgcolor

    return qr(msg, query)

  end

  query = "data=" .. url_encode(matches[1]:trim())

  return qr(msg, query)
end

return {
  description = {"qr code plugin for telegram, given a text it returns the qr code"},
  usage = {
    "!qr [text]",
    '!qr "[background color]" "[data color]" [text]',
    ".......................................................",
    "Color through text: red|green|blue|purple|black|white|gray",
    "Or colors through hex notation: (\"a56729\" is brown)",
    "Or colors through decimals: (\"255-192-203\" is pink)"
  },
  patterns = {
    '^!qr "(.+)" "(.+)" (.+)$',
    "^!qr (.+)$"
  },
  run = run
}

end
