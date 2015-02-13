
function imdb(movie)
    local http = require("socket.http")
    http.TIMEOUT = 5

    movie = movie:gsub(' ', '+')
    url = "http://www.imdbapi.com/?t=" .. movie
    response, code, headers = http.request(url)

    if code ~= 200 then
        return "Error: " .. code
    end

    if #response > 0 then
        r = json:decode(response)
        r['Url'] = "http://imdb.com/title/" .. r.imdbID
        t = ""
        for k, v in pairs(r) do t = t .. k .. ": " .. v .. ", " end
        return t:sub(1, -3)
    end
    return nil
end

function run(msg, matches)
    return imdb(matches[1])
end

return {
    description = "Imdb plugin for telegram",
    usage = "!imdb [movie]",
    patterns = {"^!imdb (.+)"},
    run = run
}
