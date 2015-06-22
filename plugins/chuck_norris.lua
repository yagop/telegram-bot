do

  local function unescape(str)
    str = string.gsub( str, '&lt;', '<' )
    str = string.gsub( str, '&gt;', '>' )
    str = string.gsub( str, '&quot;', '"' )
    str = string.gsub( str, '&apos;', "'" )
    str = string.gsub( str, '&#(%d+);', function(n) return string.char(n) end )
    str = string.gsub( str, '&#x(%d+);', function(n) return string.char(tonumber(n,16)) end )
    str = string.gsub( str, '&amp;', '&' ) -- Be sure to do this after all others
  return str
  end

  local function chuck()
    local random = http.request("http://api.icndb.com/jokes/random")
    local decode = json:decode(random)
    local joke = decode.value.joke
    local unescape = unescape(joke)
    return unescape
  end

  function run(msg)
    local joke = chuck()
    return joke
  end

  return {
    description = "Get random Chuck Norris jokes.", 
    usage = "!chuck",
    patterns = {
      "^!chuck$"
  }, 
  run = run
}

end
