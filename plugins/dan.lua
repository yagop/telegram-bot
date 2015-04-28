do
local URL = "http://danbooru.donmai.us"
local URL_NEW = "/posts.json"
local URL_POP = "/explore/posts/popular.json"

local scale_day = "?scale=day"
local scale_week = "?scale=week"
local scale_month = "?scale=month"

function get_post(url)
  local b, c, h = http.request(url)
  local posts = json:decode(b)

  -- bad random - bad magic...
  math.randomseed( os.time() )
  math.random(#posts)
  math.random(#posts)

  return posts[math.random(#posts)]
end

function run(msg, matches)

  local url = URL

  if matches[1] == "!dan" then
    url = url .. URL_NEW
  else
    url = url .. URL_POP

        if matches[1] == "!dand" then
          url = url .. scale_day
    elseif matches[1] == "!danw" then
          url = url .. scale_week
    elseif matches[1] == "!danm" then
          url = url .. scale_month
    end
  end

  local post = get_post(url)

  local receiver = get_receiver(msg)
  local img = URL .. post.large_file_url
  send_photo_from_url(receiver, img)

  local txt = 'Artist: ' .. post.tag_string_artist .. '\n'
  txt = txt .. 'Character: ' .. post.tag_string_character .. '\n'
  txt = txt .. '[' .. math.ceil(post.file_size/1000) .. 'kb] ' .. URL .. post.file_url
  return txt
end

return {
  description = "Gets a random fresh or popular image from Danbooru", 
  usage = {
    "!dan - gets a random fresh image from Danbooru 🔞",
    "!dand - random daily popular image 🔞",
    "!danw - random weekly popular image 🔞",
    "!danm - random monthly popular image 🔞"},
  patterns = {
      "^!dan$",
      "^!dand$",
      "^!danw$",
      "^!danm$"}, 
  run = run 
}

end