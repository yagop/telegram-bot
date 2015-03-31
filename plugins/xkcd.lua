do

function get_last_id()
  local res,code  = https.request("http://xkcd.com/info.0.json")
  if code ~= 200 then return "HTTP ERROR" end
  local data = json:decode(res)
  return data.num
end

function get_xkcd(id)
  local res,code  = http.request("http://xkcd.com/"..id.."/info.0.json")
  if code ~= 200 then return "HTTP ERROR" end
  local data = json:decode(res)
  local link_image = data.img
  if link_image:sub(0,2) == '//' then
    link_image = msg.text:sub(3,-1)
  end
  return link_image, data.title
end


function get_xkcd_random()
  local last = get_last_id()
  local i = math.random(1, last)
  return get_xkcd(i)
end

function send_title(cb_extra, success, result)
  if success then
    send_msg(cb_extra[1], cb_extra[2], ok_cb, false)
  end
end

function run(msg, matches)
  local receiver = get_receiver(msg)
  if matches[1] == "!xkcd" then
    url, title = get_xkcd_random()
  else
    url, title = get_xkcd(matches[1])
  end
  file_path = download_to_file(url)
  send_photo(receiver, file_path, send_title, {receiver, title})
  return false
end

return {
  description = "Send comic images from xkcd", 
  usage = {"!xkcd (id): Send an xkcd image and title. If not id, send a random one"},
  patterns = {
    "^!xkcd$",
    "^!xkcd (%d+)",
    "xkcd.com/(%d+)"
  }, 
  run = run 
}

end