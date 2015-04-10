-- See https://wiki.teamfortress.com/wiki/User:RJackson/StorefrontAPI

do

local BASE_URL = 'http://store.steampowered.com/api/appdetails/?appids='
local DESC_LENTH = 200

function unescape(str)
  str = string.gsub( str, '&lt;', '<' )
  str = string.gsub( str, '&gt;', '>' )
  str = string.gsub( str, '&quot;', '"' )
  str = string.gsub( str, '&apos;', "'" )
  str = string.gsub( str, '&#(%d+);', function(n) return string.char(n) end )
  str = string.gsub( str, '&#x(%d+);', function(n) return string.char(tonumber(n,16)) end )
  str = string.gsub( str, '&amp;', '&' ) -- Be sure to do this after all others
  return str
end

function get_steam_data (appid)
  local url = BASE_URL..appid
  local res,code  = http.request(url)
  if code ~= 200 then return nil end
  local data = json:decode(res)[appid].data
  return data
end


function send_steam_data(data, receiver)
--  local title = data.name
  local description = string.sub(unescape(data.about_the_game:gsub("%b<>", "")), 1, DESC_LENTH) .. '...'
  local title = data.name
  local price = "$"..data.package_groups[1].subs[1].price_in_cents_with_discount/100
  local percent_savings = data.package_groups[1].subs[1].percent_savings_text
  if percent_savings == "" then 
    percent_savings = "0%" 
  end
  local text = title..' '..price..' ('..percent_savings..')\n'..description
  local image_url = data.screenshots[1].path_full
  local cb_extra = {
    receiver = receiver,
    url = image_url
  }
  send_msg(receiver, text, send_photo_from_url_callback, cb_extra)
end


function run(msg, matches)
  local appid = matches[1]
  local data = get_steam_data(appid)
  local receiver = get_receiver(msg)
  send_steam_data(data, receiver)
end

return {
  description = "Grabs Steam info for Steam links.",
  usage = "",
  patterns = {
    "http://store.steampowered.com/app/([0-9]+)",
  },
  run = run
}

end
