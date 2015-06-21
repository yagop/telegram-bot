local function chuck()
  local random = http.request("http://api.icndb.com/jokes/random")
  local decode = json:decode(random)
  local joke = decode.value.joke
  local unescape = (joke)
  return unescape
end

local function run(msg)
  local joke = chuck()
  return URL.unescape(joke)
end

return {
  description = "Get random Chuck Norris jokes.", 
  usage = "!chuck",
  patterns = {
    "^!chuck$"
  }, 
  run = run
}