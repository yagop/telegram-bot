do

local OAuth = require "OAuth"

local consumer_key = ""
local consumer_secret = ""
local access_token = ""
local access_token_secret = ""

local client = OAuth.new(consumer_key, consumer_secret, {
  RequestToken = "https://api.twitter.com/oauth/request_token", 
  AuthorizeUser = {"https://api.twitter.com/oauth/authorize", method = "GET"},
  AccessToken = "https://api.twitter.com/oauth/access_token"
  }, {
  OAuthToken = access_token,
  OAuthTokenSecret = access_token_secret
})

function run(msg, matches)
  if consumer_key:isempty() then
    return "Twitter Consumer Key is empty, write it in plugins/twitter_send.lua"
  end
  if consumer_secret:isempty() then
    return "Twitter Consumer Secret is empty, write it in plugins/twitter_send.lua"
  end
  if access_token:isempty() then
    return "Twitter Access Token is empty, write it in plugins/twitter_send.lua"
  end
  if access_token_secret:isempty() then
    return "Twitter Access Token Secret is empty, write it in plugins/twitter_send.lua"
  end

  if not is_sudo(msg) then
    return "You aren't allowed to send tweets"
  end
  
  local response_code, response_headers, response_status_line, response_body = 
  client:PerformRequest("POST", "https://api.twitter.com/1.1/statuses/update.json", {
    status = matches[1]
    })
  if response_code ~= 200 then
    return "Error: "..response_code
  end
  return "Tweet sended"
end

return {
  description = "Sends a tweet", 
  usage = "!tw [text]: Sends the Tweet with the configured accout.",
  patterns = {"^!tw (.+)"}, 
  run = run
}

end