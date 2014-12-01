
function delay_s(delay)
   delay = delay or 1
   local time_to = os.time() + delay
   while os.time() < time_to do end
end

function run(msg, matches)
  local loc = string.gsub(matches[1], "%s+", "+")
  local receiver = get_receiver(msg)

  local zooms = {16, 18}

  for i = 1, #zooms do
    local zoom = zooms[i]
    local url = "http://maps.googleapis.com/maps/api/staticmap?zoom=" .. zoom .. "&size=600x300&maptype=roadmap&center=" .. loc .. "&markers=color:blue%7Clabel:A%7C" .. loc
    local file = download_to_file(url)
    send_photo(receiver, file, ok_cb, false)
    delay_s(2)
  end

  return "www.google.es/maps/place/" .. loc
end

return {
    description = "generates a map showing the given location", 
    usage = "!loc (location)",
    patterns = {"^!loc (.*)$"}, 
    run = run 
}

