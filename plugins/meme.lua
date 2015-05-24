do

-- Main function
  local function meme(msg, meme, top, bottom)
    local http = require("socket.http")
    local meme = meme:gsub(' ', '+')
    local top = top:gsub(' ', '+')
    local bottom = bottom:gsub(' ', '+')
    local url = "http://apimeme.com/meme?meme=" .. meme .. "&top=" .. top .. "&bottom=" .. bottom
    local response, code, headers = http.request(url)
    local receiver = get_receiver(msg)

    if code ~= 200 then
      return ":( Error: " .. code
    end

    if #response > 0 then
  	send_photo_from_url(receiver, url)
  	return

    end
    return ":( something strange happened"
  end



local function run(msg, matches)

    return meme(msg, matches[1],matches[2], matches[3])

end


return {
  description = "qr code plugin for telegram, given a text it returns the qr code",
  usage = [[!meme [meme name],  [top text], [bottom text]
  here THE list of memes avaiable: http://pastebin.com/jzsmdFLD
]],
  patterns = {"^!meme (.+), (.+), (.+)"},
  run = run
}

end
