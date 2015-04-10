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
  local description = string.sub(unescape(data.about_the_game:gsub("%b<>", "")), 1, DESC_LENTH) .. '...'
  local title = data.name
  local price = "$"..(data.price_overview.initial/100)
  local sale_price = "$"..(data.price_overview.final/100)
  local percent_savings = data.price_overview.discount_percent
  local price_display = price 

  if percent_savings ~= 0 then 
    price_display = price.." -> "..sale_price.." ("..percent_savings.."%)" 
  end

  local text = title..' '..price_display..'\n'..description
  local image_url = data.header_image
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
