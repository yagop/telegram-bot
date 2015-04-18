do

local BASE_URL = "http://api.openweathermap.org/data/2.5"

function get_weather(location)
  print("Finding weather in ", location)
  local b, c, h = http.request(BASE_URL.."/weather?q=" .. location .. "&units=metric")
  local weather = json:decode(b)
  print("Weather returns", weather)
  local city = weather.name
  local country = weather.sys.country
  local temp =  city .. ' (' .. country .. ') '
  temp = temp .. 'Temp: ' .. weather.main.temp .. '°C'
  local conditions = 'Conditions: ' .. weather.weather[1].description
  
  if weather.weather[1].main == 'Clear' then
    conditions = conditions .. ' ☀'
  elseif weather.weather[1].main == 'Clouds' then
    conditions = conditions .. ' ☁☁'
  elseif weather.weather[1].main == 'Rain' then
    conditions = conditions .. ' ☔'
  elseif weather.weather[1].main == 'Thunderstorm' then
    conditions = conditions .. ' ☔☔☔☔'
  end

  local wind = "Wind: " 


  if     weather.wind.deg > 326.25 and weather.wind.deg <= 348.75 then wind = wind .. 'NNW'
  elseif weather.wind.deg > 303.75 and weather.wind.deg <= 326.25 then wind = wind .. 'NW'
  elseif weather.wind.deg > 281.25 and weather.wind.deg <= 303.75 then wind = wind .. 'WNW'
  elseif weather.wind.deg > 258.75 and weather.wind.deg <= 281.25 then wind = wind .. 'W'
  elseif weather.wind.deg > 236.25 and weather.wind.deg <= 258.75 then wind = wind .. 'WSW'
  elseif weather.wind.deg > 213.75 and weather.wind.deg <= 236.25 then wind = wind .. 'SW'
  elseif weather.wind.deg > 191.25 and weather.wind.deg <= 213.75 then wind = wind .. 'SSW'
  elseif weather.wind.deg > 168.75 and weather.wind.deg <= 191.25 then wind = wind .. 'S'
  elseif weather.wind.deg > 146.25 and weather.wind.deg <= 168.75 then wind = wind .. 'SSE'
  elseif weather.wind.deg > 101.25 and weather.wind.deg <= 123.75 then wind = wind .. 'ESE'
  elseif weather.wind.deg > 78.75  and weather.wind.deg <= 101.25 then wind = wind .. 'E'
  elseif weather.wind.deg > 56.25  and weather.wind.deg <= 78.75  then wind = wind .. 'ENE'
  elseif weather.wind.deg > 33.75  and weather.wind.deg <= 56.25  then wind = wind .. 'NE'
  elseif weather.wind.deg > 11.25  and weather.wind.deg <= 33.75  then wind = wind .. 'NNE'
  elseif weather.wind.deg > 348.75 and weather.wind.deg <= 11.25  then wind = wind .. 'N'
  end

  wind = wind .. ' ' .. weather.wind.speed .. "m/s"

  return temp .. '\n' .. conditions .. '\n' .. wind
end

function run(msg, matches)
  if string.len(matches[1]) > 2 then 
    city = matches[1]
  else
    city = "Kyiv"
  end
  return get_weather(city)
end

return {
  description = "weather in that city (Kyiv is default)", 
  usage = "!weather (city)",
  patterns = {"^!weather%s?(.*)$"}, 
  run = run 
}

end