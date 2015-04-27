do

local function run(msg, matches)
  -- Parse URL from input, default to http
  local parsed_url = URL.parse(matches[1],  { scheme = 'http', authority = '' })
  -- Fix URLs without subdomain not parsed properly
  if not parsed_url.host and parsed_url.path then
    parsed_url.host = parsed_url.path
    parsed_url.path = ""
  end
  -- Re-build URL
  local url = URL.build(parsed_url)

  local protocols = {
    ["https"] = https,
    ["http"] = http
  }
  local options =  {
    url = url,
    redirect = false,
    method = "GET"
  }
  response = { protocols[parsed_url.scheme].request(options) }
  local code = tonumber(response[2])
  if code == nil or code >= 400 then
    return url.." looks down from here."
  end

  return url.." looks up from here."
end

return {
  description = "Check if a website is up or not.",
  usage = "/isup <site>: Checks if a website is up or not",
  patterns = {"^/isup (.*)$"},
  run = run
}

end