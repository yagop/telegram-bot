local function request(text)
   local api = "https://yoda.p.mashape.com/yoda?"
   text = string.gsub(text, " ", "+")
   local parameters = "sentence="..(text or "")
   local url = api..parameters
   local https = require("ssl.https")
   local respbody = {}
   local ltn12 = require "ltn12"
   local headers = {
      ["X-Mashape-Key"] = "5j2cydo37tmshgTnssARJN6VuGqkp1ggaTojsnP2fharkD2Uir",
      ["Accept"] = "text/plain"
   }
   print(url)
   local body, code, headers, status = https.request{
      url = url,
      method = "GET",
      headers = headers,
      sink = ltn12.sink.table(respbody),
      protocol = "tlsv1"
   }
   if code ~= 200 then return code end
   local body = table.concat(respbody)
   print(body)
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
