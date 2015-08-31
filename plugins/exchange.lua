local ltn12 = require "ltn12"
local https = require "ssl.https"

-- Edit data/mashape.lua with your Mashape API key
-- http://docs.mashape.com/api-keys

local function comma_value(n) -- credit http://richard.warburton.it
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

local mashape = load_from_file('data/mashape.lua', {
      api_key = ''
   })

local function request(value, from, to)
   local api = "https://currency-exchange.p.mashape.com/exchange?"
   local par1 = "from="..from
   local par2 = "&q="..value
   local par3 = "&to="..to
   local url = api..par1..par2..par3

   local api_key = mashape.api_key
   if api_key:isempty() then
      return 'Configure your Mashape API Key'
   end

   local headers = {
      ["X-Mashape-Key"] = api_key,
      ["Accept"] = "text/plain"
   }

   local respbody = {}
   local body, code  = https.request{
      url = url,
      method = "GET",
      headers = headers,
      sink = ltn12.sink.table(respbody),
      protocol = "tlsv1"
   }
   if code ~= 200 then return code end
   local body = table.concat(respbody)
   local curr = comma_value(value).." "..from.." = "..to.." "..comma_value(body)
   return curr
end

local function run(msg, matches)
    if tonumber(matches[1]) and not matches[2] then
        local from = "USD"
        local to = "IDR"
        local value = matches[1]
        return request(value, from, to)
    elseif matches[2] and matches[3] then
        local from = string.upper(matches[2]) or "USD"
        local to = string.upper(matches[3]) or "IDR"
        local value = matches[1] or "1"
        return request(value, from, to, value)
    end
end

return {
   description = "Currency Exchange",
   usage = {
   "!exchange [value] : Exchange value from USD to IDR (default).",
   "!exchange [value] [from] [to] : Get Currency Exchange by specifying the value of source (from) and destination (to).",
   },
   patterns = {
      "^!exchange (%d+) (%a+) (%a+)$",
      "^!exchange (%d+)",
   },
   run = run
}
