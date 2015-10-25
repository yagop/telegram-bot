do

local function imdb(movie)
  local http = require("socket.http")
  local movie = movie:gsub(' ', '+')
  local url = "http://www.omdbapi.com/?t=" .. movie
  local response, code, headers = http.request(url)

  if code ~= 200 then
    return "Error: " .. code
  end

  if #response > 0 then
    local r = json:decode(response)
    vardump(r)
    if r.Error then
      return r.Error
    end
    r['Url'] = "http://omdb.com/title/" .. r.imdbID
    local t = ""
    for k, v in pairs(r) do
      t = t..k..": "..v.. "\n"
    end
    return t
  end
  return nil
end

local function run(msg, matches)
  return imdb(matches[1])
end

return {
  description = "IMDB plugin for telegram",
  usage = "!imdb [movie]",
  patterns = {"^!imdb (.+)"},
  run = run
}

end
