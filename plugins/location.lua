-- Implement a command !loc [area] which uses
-- the static map API to get a location image

-- Not sure if this is the proper way
-- Intent: get_latlong is in time.lua, we need it here
-- loadfile "time.lua"

-- Globals
-- If you have a google api key for the geocoding/timezone api
do

local api_key = nil

local base_api = "https://maps.googleapis.com/maps/api"

function get_staticmap(area)
  local api        = base_api .. "/staticmap?"

  -- Get a sense of scale
  local lat,lng,acc,types = get_latlong(area)

  local scale = types[1]
  if     scale=="locality" then zoom=8
  elseif scale=="country"  then zoom=4
  else zoom = 13 end
    
  local parameters =
    "size=600x300" ..
    "&zoom="  .. zoom ..
    "&center=" .. URL.escape(area) ..
    "&markers=color:red"..URL.escape("|"..area)

  if api_key ~=nil and api_key ~= "" then
    parameters = parameters .. "&key="..api_key
  end
  return lat, lng, api..parameters
end


function run(msg, matches)
  local receiver	= get_receiver(msg)
  local lat,lng,url	= get_staticmap(matches[1])

  -- Send the actual location, is a google maps link
  send_location(receiver, lat, lng, ok_cb, false)

  -- Send a picture of the map, which takes scale into account
  send_photo_from_url(receiver, url)

  -- Return a link to the google maps stuff is now not needed anymore
  return nil
end

return {
  description = "Gets information about a location, maplink and overview", 
  usage = "!loc (location): Gets information about a location, maplink and overview",
  patterns = {"^!loc (.*)$"}, 
  run = run 
}

end