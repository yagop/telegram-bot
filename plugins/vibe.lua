local MashapeKey = "KEY"

local function getMostSentimentalWord(t, isPositive)
    local mostSentimental = {word = "", score = 0}
    for key, value in pairs (t) do
        if isPositive and value.score > mostSentimental.score then
            mostSentimental = value
        elseif (not isPositive) and value.score < mostSentimental.score then
            mostSentimental = value
        end
    end
    return mostSentimental.word
end

local function request(text)
   local api = "https://twinword-sentiment-analysis.p.mashape.com/analyze/"
   local reqbody = "text="..(URL.escape(text) or "")
   local url = api
   local https = require("ssl.https")
   local respbody = {}
   local ltn12 = require "ltn12"
   local headers = {
      ["X-Mashape-Key"] = MashapeKey,
      ["Accept"] = "application/json",
      ["Content-Type"] = "application/x-www-form-urlencoded",
      ["Content-Length"] = string.len(reqbody)
   }
   print(url)
   local body, code, headers, status = https.request{
      url = url,
      method = "POST",
      headers = headers,
      sink = ltn12.sink.table(respbody),
      protocol = "tlsv1",
      source = ltn12.source.string(reqbody)
   }
   if code ~= 200 then return code end
   local body = table.concat(respbody)
   local jsonBody = json:decode(body)
   local response = ""
   if jsonBody.score == nil or jsonBody.type == nil then return "Error." end
   if jsonBody.type == "positive" then
      response = response .. "I feel those positive vibes like sugar in my mouth! I love the word \"" .. getMostSentimentalWord(jsonBody.keywords, true) .. "\"!"
   elseif jsonBody.type == "neutral" then
      response = response .. "Ok... Nothing interesting about that. Not good, not bad..."
   elseif jsonBody.type == "negative" then
      response = response .. "I feel those positive vibes like salt in my mouth! I hate the word \"" .. getMostSentimentalWord(jsonBody.keywords, false) .. "\"!"
   else return "Error." end
   return response
end

local function run(msg, matches)
   return request(matches[1])
end

return {
   description = "Check if a sentence has positive or negative vibes!",
   usage = "!vibe [text]",
   patterns = {
      "^![V|v]ibe (.*)$"
   },
   run = run
}
