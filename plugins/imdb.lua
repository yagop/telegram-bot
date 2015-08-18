do

function imdb(msg, movie)
  local http = require("socket.http")
  local movie = movie:gsub(' ', '+')
  local url = "http://www.imdbapi.com/?t=" .. movie
  local response, code, headers = http.request(url)

  if code ~= 200 then
    return "Error: " .. code
  end

  if #response > 0 then
    local r = json:decode(response)
    r['Url'] = "http://imdb.com/title/" .. r.imdbID
    local t = ""
    for k, v in pairs(r) do
      if not string.match(k, 'Poster') then
        t = t .. k .. ": " .. v .. ".\n"
      end
    end

    local receiver = get_receiver(msg)
    send_photo_from_url(receiver, r['Poster'])

    return t:sub(1, -3)
  end
  return nil
end

local function run(msg, matches)
  return imdb(msg, matches[1])
end

return {
  description = "IMDB plugin for telegram",
  usage = "!imdb [movie]",
  patterns = {"^!imdb (.+)"},
  run = run
}

end
