local ltn12 = require "ltn12"
local https = require "ssl.https"

-- Edit data/mashape.lua with your Mashape API key
-- http://docs.mashape.com/api-keys

local mashape = load_from_file('data/mashape.lua', {
      api_key = ''
   })

local function check(name)
		local api = "https://domainsearch.p.mashape.com/index.php?"
		local param = "name="..name
		local url = api..param
		local api_key = mashape.api_key
		if api_key:isempty() then
      return 'Configure your Mashape API Key'
   end
   local headers = {
      ["X-Mashape-Key"] = api_key,
      ["Accept"] = "application/json"
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
   local body = json:decode(body)
   --vardump(body)
   local domains = "List of domains for '"..name.."':\n"
   for k,v in pairs(body) do
   	print(k)
   	local status = " ❌ "
   	if v == "Available" then
   		status = " ✔ "
   	end
   	domains = domains..k..status.."\n"
   end
   return domains
end

local function run(msg, matches)
    if matches[1] == "check" then
    	local name = matches[2]
    	return check(name)
    end
end

return {
   description = "Domain tools",
   usage = {"!domain check [domain] : Check domain name availability.",
   },
   patterns = {
      "^!domain (check) (.*)$",
   },
   run = run
}
