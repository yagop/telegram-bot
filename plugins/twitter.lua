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
    return "Twitter Consumer Key is empty, write it in plugins/twitter.lua"
  end
  if consumer_secret:isempty() then
    return "Twitter Consumer Secret is empty, write it in plugins/twitter.lua"
  end
  if access_token:isempty() then
    return "Twitter Access Token is empty, write it in plugins/twitter.lua"
  end
  if access_token_secret:isempty() then
    return "Twitter Access Token Secret is empty, write it in plugins/twitter.lua"
  end

  local twitter_url = "https://api.twitter.com/1.1/statuses/show/" .. matches[1] .. ".json"
  local response_code, response_headers, response_status_line, response_body = client:PerformRequest("GET", twitter_url)
  local response = json:decode(response_body)

  local header = "Tweet from " .. response.user.name .. " (@" .. response.user.screen_name .. ")\n"
  local text = response.text
  
  -- replace short URLs
  if response.entities.url then
    for k, v in pairs(response.entities.urls) do 
      local short = v.url
      local long = v.expanded_url
      text = text:gsub(short, long)
    end
  end
  
  -- remove images
  local images = {}
  if response.extended_entities and response.extended_entities.media then
    for k, v in pairs(response.extended_entities.media) do
      local url = v.url
      local pic = v.media_url
      text = text:gsub(url, "")
      table.insert(images, pic)
    end
  end

  -- send the parts 
  local receiver = get_receiver(msg)
  send_msg(receiver, header .. "\n" .. text, ok_cb, false)
  send_photos_from_url(receiver, images)
  return nil
end
 

return {
  description = "When user sends twitter URL, send text and images to origin. Requires OAuth Key.", 
  usage = "",
  patterns = {
    "https://twitter.com/[^/]+/status/([0-9]+)"
  }, 
  run = run 
}
