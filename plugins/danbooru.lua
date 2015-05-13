do
local URL = "http://danbooru.donmai.us"
local URL_NEW = "/posts.json"
local URL_POP = "/explore/posts/popular.json"

local scale_day = "?scale=day"
local scale_week = "?scale=week"
local scale_month = "?scale=month"

local function get_post(url)
  local b, c, h = http.request(url)
  if c ~= 200 then return nil end
  local posts = json:decode(b)

  return posts[math.random(#posts)]
end

local function run(msg, matches)

  local url = URL

  if matches[1] == "!danbooru" then
    url = url .. URL_NEW
  else
    url = url .. URL_POP

    if matches[1] == "d" then
      url = url .. scale_day
    elseif matches[1] == "w" then
      url = url .. scale_week
    elseif matches[1] == "m" then
      url = url .. scale_month
    end
  end

  local post = get_post(url)

  if post then
    vardump(post)
    local img = URL .. post.large_file_url
    send_photo_from_url(get_receiver(msg), img)

    local txt = ''
    if post.tag_string_artist ~= '' then
      txt = 'Artist: ' .. post.tag_string_artist .. '\n'
    end
    if post.tag_string_character ~= '' then
      txt = txt .. 'Character: ' .. post.tag_string_character .. '\n'
    end
    if post.file_size ~= '' then
      txt = txt .. '[' .. math.ceil(post.file_size/1000) .. 'kb] ' .. URL .. post.file_url
    end
    return txt
  end
end

return {
  description = "Gets a random fresh or popular image from Danbooru", 
  usage = {
    "!danbooru - gets a random fresh image from Danbooru 🔞",
    "!danboorud - random daily popular image 🔞",
    "!danbooruw - random weekly popular image 🔞",
    "!danboorum - random monthly popular image 🔞"
  },
  patterns = {
    "^!danbooru$",
    "^!danbooru ?(d)$",
    "^!danbooru ?(w)$",
    "^!danbooru ?(m)$"
  },
  run = run 
}

end