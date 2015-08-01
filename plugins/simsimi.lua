
--[[
-- http://www.simsimi.com/requestChat?lc=en&ft=1.0&req=Who%20are%20you
--]]
do

function ngomong(text)
  local path = "http://www.simsimi.com/requestChat"
  -- URL query parameters
  local params = {
    lc = "id",
    ft = "1.0",
    req = URL.escape(text)
  }

  local query = format_http_params(params, true)
  local url = path..query
  local b,c = http.request(url)
  if c ~= 200 then return nil end
  local says = json:decode(b)
  local speak = says.res
  return speak
end

function run(msg, matches)
  local text = matches[1]
  return ngomong(text)
end

return {
  description = "Clever bot", 
  usage = {
    "!ell Whatever you want to say",
  },
  patterns = {
    "^!ell (.+)"
  }, 
  run = run 
}

end
