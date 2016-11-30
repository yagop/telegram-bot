do

function run(msg, matches)
  local lat = matches[1]
  local lon = matches[2]
  local receiver = get_receiver(msg)

  local zooms = {15}
  local urls = {}
  for i = 1, #zooms do
    local zoom = zooms[i]
    local url = "http://maps.googleapis.com/maps/api/staticmap?zoom=" .. zoom .. "&size=600x300&maptype=roadmap&center=" .. lat .. "," .. lon .. "&markers=color:blue%7Clabel:X%7C" .. lat .. "," .. lon
    table.insert(urls, url)
  end

  send_photos_from_url(receiver, urls)

  return "www.google.com/maps/place/@" .. lat .. "," .. lon .. ",17z"
end

return {
  description = "generates a map showing the given GPS coordinates",
  usage = "!gps latitude,longitude: generates a map showing the given GPS coordinates (example: !gps 50.449859,30.524089)",
  patterns = {"^!gps ([^,]*)[,%s]([^,]*)$"}, 
  run = run 
}

end