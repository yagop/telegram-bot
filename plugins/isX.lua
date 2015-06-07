local https = require "ssl.https"
local ltn12 = require "ltn12"

local function request(imageUrl)
   -- Edit data/mashape.lua with your Mashape API key
   -- http://docs.mashape.com/api-keys
   local mashape = load_from_file('data/mashape.lua', {
         api_key = ''
      })

   local api_key = mashape.api_key
   if api_key:isempty() then
      return nil, 'Configure your Mashape API Key'
   end

   local api = "https://sphirelabs-advanced-porn-nudity-and-adult-content-detection.p.mashape.com/v1/get/index.php?"
   local parameters = "&url="..(URL.escape(imageUrl) or "")
   local url = api..parameters
   local respbody = {}
   local headers = {
      ["X-Mashape-Key"] = api_key,
      ["Accept"] = "Accept: application/json"
   }
   print(url)
   local body, code, headers, status = https.request{
      url = url,
      method = "GET",
      headers = headers,
      sink = ltn12.sink.table(respbody),
      protocol = "tlsv1"
   }
   if code ~= 200 then return "", code end
   local body = table.concat(respbody)
   return body, code
end

local function parseData(data)
   local jsonBody = json:decode(data)
   local response = ""
   print(data)
   if jsonBody["Error Occured"] ~= nil then
      response = response .. jsonBody["Error Occured"]
   elseif jsonBody["Is Porn"] == nil or jsonBody["Reason"] == nil then
      response = response .. "I don't know if that has adult content or not."
   else
      if jsonBody["Is Porn"] == "True" then
         response = response .. "Beware!\n"
      end
      response = response .. jsonBody["Reason"]
   end
   return jsonBody["Is Porn"], response
end

local function run(msg, matches)
   local data, code = request(matches[1])
   if code ~= 200 then return "There was an error. "..code end
   local isPorn, result = parseData(data)
   return result
end

return {
   description = "Does this photo contain adult content?",
   usage = {
      "!isx [url]",
      "!isporn [url]"
   },
   patterns = {
      "^!is[x|X] (.*)$",
      "^!is[p|P]orn (.*)$"
   },
   run = run
}