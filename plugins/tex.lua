do


function escape(s)
  return (string.gsub(s, "([^A-Za-z0-9_])", function(c)
    return string.format("%%%02x", string.byte(c))
  end))
end

local function run(msg, matches)
  local eq = matches[1]
  local url = "http://latex.codecogs.com/gif.latex?" .. escape(eq)
  local receiver = get_receiver(msg)
  send_photo_from_url(receiver, url)
end

return {
  description = "Latex equation to image",
  usage = {
    "!tex equation: Get image from equation"
  },
  patterns = {
    "!tex (.*)"
  },
  run = run
}

end

