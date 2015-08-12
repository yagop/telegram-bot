local function chuck()
  local random = http.request("http://api.icndb.com/jokes/random")
  local decode = json:decode(random)
  local joke = decode.value.joke
  return joke
end

local function run(msg)
  local joke = chuck()
  return unescape_html(joke)
end

return {
  description = "Get random Chuck Norris jokes.", 
  usage = "!chuck",
  patterns = {
    "^!chuck$"
  }, 
  run = run
}