local OAuth = require "OAuth"

local consumer_key = config.twitter.consumer_key
local consumer_secret = config.twitter.consumer_secret
local access_token = config.twitter.access_token
local access_token_secret = config.twitter.access_token_secret

local client = OAuth.new(consumer_key, consumer_secret, {
    RequestToken = "https://api.twitter.com/oauth/request_token", 
    AuthorizeUser = {"https://api.twitter.com/oauth/authorize", method = "GET"},
    AccessToken = "https://api.twitter.com/oauth/access_token"
}, {
    OAuthToken = access_token,
    OAuthTokenSecret = access_token_secret
})

function run(msg, matches)

	local response_code, response_headers, response_status_line, response_body = 
    client:PerformRequest("POST", "https://api.twitter.com/1.1/statuses/update.json", {
    	status = matches[1]
    })
    if response_code ~= 200 then
    	return "Error: "..response_code
    end
	return "Tweet enviado"
end

return {
    description = "Sends a tweet", 
    usage = "!tw [text]",
    patterns = {"^!tw (.+)"}, 
    run = run
}