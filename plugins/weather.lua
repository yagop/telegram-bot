
function get_weather(location)
   print("Finding weather in ", location)
   b, c, h = http.request("http://api.openweathermap.org/data/2.5/weather?q=" .. location .. "&units=metric")
   weather = json:decode(b)
   print("Weather returns", weather)
   local city = weather.name
   local country = weather.sys.country
   temp = 'The temperature in ' .. city .. ' (' .. country .. ')'
   temp = temp .. ' is ' .. weather.main.temp .. '°C'
   conditions = 'Current conditions are: ' .. weather.weather[1].description
   if weather.weather[1].main == 'Clear' then
	  conditions = conditions .. ' ☀'
   elseif weather.weather[1].main == 'Clouds' then
	  conditions = conditions .. ' ☁☁'
   elseif weather.weather[1].main == 'Rain' then
	  conditions = conditions .. ' ☔'
   elseif weather.weather[1].main == 'Thunderstorm' then
	  conditions = conditions .. ' ☔☔☔☔'
   end
   return temp .. '\n' .. conditions
end

function run(msg, matches)
    if string.len(matches[1]) > 2 then 
        city = matches[1]
    else
        city = "Madrid,ES"
    end
    return get_weather(city)
end

return {
    description = "weather in that city (Madrid is default)", 
    usage = "!weather (city)",
    patterns = {"^!weather(.*)$"}, 
    run = run 
}

