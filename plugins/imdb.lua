do

local function imdb(movie)
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
    for k, v in pairs(r) do t = t .. k .. ": " .. v .. ", " end
    return t:sub(1, -3)
  end
  return nil
end

local function run(msg, matches)
  return imdb(matches[1])
end

return {
  description = "Imdb plugin for telegram",
  usage = "!imdb [movie]",
  patterns = {"^!imdb (.+)"},
  run = run
}

end