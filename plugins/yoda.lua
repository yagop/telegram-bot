local ltn12 = require "ltn12"
local https = require "ssl.https"

-- Edit data/mashape.lua with your Mashape API key
-- http://docs.mashape.com/api-keys
local mashape = load_from_file('data/mashape.lua', {
      api_key = ''
   })

local function request(text)
   local api = "https://yoda.p.mashape.com/yoda?"
   text = string.gsub(text, " ", "+")
   local parameters = "sentence="..(text or "")
   local url = api..parameters

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
   return body
end

local function run(msg, matches)
   return request(matches[1])
end

return {
   description = "Listen to Yoda and learn from his words!",
   usage = "!yoda You will learn how to speak like me someday.",
   patterns = {
      "^![y|Y]oda (.*)$"
   },
   run = run
}
