do

local titRuPattern1 = "^Раб.*сис.*"
local titRuPattern2 = "^раб.*сис.*"
local butRuPattern1 = "^Раб.*поп.*"
local butRuPattern2 = "^раб.*поп.*"

function getRandomButts(attempt)
  attempt = attempt or 0
  attempt = attempt + 1

  local res,status = http.request("http://api.obutts.ru/noise/1")

  if status ~= 200 then return nil end
  local data = json:decode(res)[1]

  -- The OpenBoobs API sometimes returns an empty array
  if not data and attempt < 10 then 
    print('Cannot get that butts, trying another ones...')
    return getRandomButts(attempt)
  end

  return 'http://media.obutts.ru/' .. data.preview
end

function getRandomBoobs(attempt)
  attempt = attempt or 0
  attempt = attempt + 1

  local res,status = http.request("http://api.oboobs.ru/noise/1")

  if status ~= 200 then return nil end
  local data = json:decode(res)[1]

  -- The OpenBoobs API sometimes returns an empty array
  if not data and attempt < 10 then 
    print('Cannot get that boobs, trying another ones...')
    return getRandomBoobs(attempt)
  end

  return 'http://media.oboobs.ru/' .. data.preview
end

function run(msg, matches)
  local url = nil
  
  if matches[1] == "!boobs" or (string.match(matches[1], titRuPattern1) and is_sudo(msg)) or (string.match(matches[1], titRuPattern2)  and is_sudo(msg)) then
    url = getRandomBoobs()
  end

  if matches[1] == "!butts" or (string.match(matches[1], butRuPattern1) and is_sudo(msg)) or (string.match(matches[1], butRuPattern2) and is_sudo(msg)) then
    url = getRandomButts()
  end

  if url ~= nil then
    local receiver = get_receiver(msg)
    send_photo_from_url(receiver, url)
  else
    return 'Error getting boobs/butts for you, please try again later.' 
  end
end

return {
  description = "Gets a random boobs or butts pic", 
  usage = {
    "!boobs",
    "!butts"
  },
  patterns = {
    "^!boobs$",
    "^!butts$",
    titRuPattern1,
    titRuPattern2,
    butRuPattern1,
    butRuPattern2
  }, 
  run = run 
}

end
