do

function getGoogleImage(text)
  local text = URL.escape(text)
  local api = "https://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=8&q="
  local res, code = http.request(api..text)
  if code ~= 200 then return nil end
  local google = json:decode(res)

  if google.responseStatus ~= 200 then
    return nil
  end

  -- Google response Ok
  local i = math.random(#google.responseData.results) -- Random image from results
  return google.responseData.results[i].url

end

function run(msg, matches)
  local receiver = get_receiver(msg)
  local text = msg.text:sub(6,-1)
  local url = getGoogleImage(text)
  print("Image URL: ", url)
  send_photo_from_url(receiver, url)
end

return {
    description = "Search image with Google API and sends it.", 
    usage = "!img [term]: Random search an image with Google API.",
    patterns = {"^!img (.*)$"}, 
    run = run 
}

end