do

local http = require("socket.http")

function table_print (tt, indent, done)
  done = done or {}
  indent = indent or 0
  if type(tt) == "table" then
    local sb = {}
    for key, value in pairs (tt) do
      table.insert(sb, string.rep (" ", indent)) -- indent it
      if type (value) == "table" and not done [value] then
        done [value] = true
        table.insert(sb, key.." = {\n");
        table.insert(sb, table_print (value, indent + 2, done))
        table.insert(sb, string.rep (" ", indent)) -- indent it
        table.insert(sb, "}\n");
      elseif "number" == type(key) then
        table.insert(sb, string.format("\"%s\"\n", tostring(value)))
      else
        table.insert(sb, string.format(
            "%s = \"%s\"\n", tostring (key), tostring(value)))
       end
    end
    return table.concat(sb)
  else
    return tt .. "\n"
  end
end

function to_string( tbl )
    if  "nil"       == type( tbl ) then
        return tostring(nil)
    elseif  "table" == type( tbl ) then
        return table_print(tbl)
    elseif  "string" == type( tbl ) then
        return tbl
    else
        return tostring(tbl)
    end
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function getData (station, showTaf)
  function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
  end
  -- generate taf argument
  local tafCode = "off"
  if showTaf then
    tafCode = "on"
  end
  
  -- make request
  local r, e = http.request("https://www.aviationweather.gov/metar/data?ids="..station.."&format=raw&date=0&hours=0&taf="..tafCode);
  if tonumber(e) ~= 200 then
    return nil, nil, e
  end
  
  -- find start and end point of data
  local i = string.find(r, "<!-- Data starts here -->", 1, true)
  local finish = string.find(r, "<!-- Data ends here -->", 1, true)
  
  -- buffers
  local metar, taf
  local buf = ""
  
  local inElement = false
  while true do
    -- get current char
    local c = string.sub(r, i, i)
    if c == nil then
      break
    elseif i == finish then
      break
    end
    
    if c == "<" then -- inside an element
      buf = trim(buf)
      if buf ~= "" then -- data stored
        if metar == nil then -- no metar yet
          metar = buf
          buf = ""
          if not showTaf then
            break -- done
          end
        else
          taf = buf
        end
      end
      inElement = true
    end
    
    if not inElement then -- relevant data
      buf = buf .. c
    end
    
    if c == ">" then -- out of element
      inElement = false
    end
    
    -- next char
    i = i + 1
  end
  
  -- trim output and remove &nbsp;
  metar = trim(metar)
  if showTaf then
    taf = trim(taf)
    taf = taf:gsub("&nbsp;", " ")
    taf = taf:sub(5)
  end
  
  return metar, taf, e
end


function parseMetarOrTafReport(s)
  local report = {}
  local part = {}
  report.string = s
  
  local i = 1
  
  -- string functions
  function substring(l)
    local r = s:sub(i, i + l - 1)
    skip(l)
    return r
  end
  
  function skipWhitespaces()
    while s:sub(i, i):find("%s") ~= nil do
      skip()
    end
  end
  
  function skip(l)
    if not l then
      l = 1
    end
    i = i + l
  end
  
  function test(j, c, l)
    if not l then l = #c end
    return s:sub(i + j, i + j + l - 1):match(c) ~= nil
  end
  
  function nextGroupLength()
    local l = 0
    while not test(l, "%s", 1) and l + i <= #s do
      l = l + 1
    end
    return l
  end
  
  
  -- parse
  
  -- station
  report.station = substring(4)
  skipWhitespaces()
  
  -- time
  report.time = {}
  report.time.day = substring(2)
  report.time.hour = substring(2)
  report.time.minute = substring(2)
  skip(1) -- Z (zulu time)
  skipWhitespaces()
  
  while true do
    -- effective time
    if test(4, "/") then
      part.effective = {}
      part.effective.from = {}
      part.effective.from.day = substring(2)
      part.effective.from.hour = substring(2)
      skip(1)
      part.effective.to = {}
      part.effective.to.day = substring(2)
      part.effective.to.hour = substring(2)
      skipWhitespaces()
    end
    
    -- wind
    if nextGroupLength() == 7 or (test(5, "G") and nextGroupLength() == 10) then
      part.wind = {}
      part.wind.dir = substring(3)
      part.wind.force = substring(2)
      -- gust?
      if test(0, "G") then
        skip(1) -- G
        part.wind.gust = substring(2)
      end
      skip(2) -- KT
      skipWhitespaces()
      -- drift?
      if test(3, "V") then
        part.wind.drift = {}
        part.wind.drift.min = substring(3)
        skip(1) -- V
        part.wind.drift.max = substring(3)
        skipWhitespaces()
      end
    end
    
    
    -- cavok or visibility
    if test(0, "CAVOK") then
      part.cavok = true
      skip(5)
      skipWhitespaces()
    elseif test(0, "%d%d%d%d", 4) then
      -- visibility
      part.visibility = {}
      -- ground
      part.visibility.ground = {}
      part.visibility.ground.min = {}
      part.visibility.ground.min.length = substring(4)
      if test(1, " ") then
        part.visibility.ground.min.dir = substring(1)
      elseif test(2, " ") then
        part.visibility.ground.min.dir = substring(2)
      end
      skipWhitespaces()
      
      if test(0, "%d", 1) then
        part.visibility.ground.max = {}
        part.visibility.ground.max.length = substring(4)
        if test(1, " ") then
          part.visibility.ground.max.dir = substring(1)
        elseif test(2, " ") then
          part.visibility.ground.max.dir = substring(2)
        end
        skipWhitespaces()
      end
      
      -- runway
      while test(0, "R") do
        skip(1) -- R
        local runway = {}
        if test(2, "/") then
          runway.name = substring(2)
        else
          runway.name = substring(3)
        end
        skip(1) -- slash
        runway.dist = substring(4)
        runway.trendKey = substring(1)
        if runway.trendKey == "V" then
          runway.variation = substring(4)
          runway.trendKey = substring(1)
        end
        if runway.trendKey == "U" then
          runway.trend = "becoming better"
        elseif runway.trendKey == "D" then
          runway.trend = "becoming worse"
        elseif runway.trendKey == "N" then
          runway.trend = "not changing"
        end
        if part.visibility.runway == nil then
          part.visibility.runway = {}
        end
        table.insert(part.visibility.runway, runway)
        skipWhitespaces()
      end
    end
    
    -- weather or vertical visibility
    if test(0, "SKC") then
      part.skyclear = true
      skip(3) -- SKC
    elseif test(0, "VV") then
      skip(2) -- VV
      part.visibility.vertical = substring(3).."00"
    elseif test(0, "-") or test(0, "+") or nextGroupLength() == 4 or nextGroupLength() == 3 or nextGroupLength() == 2 then
      if not test(3, "%d", 1) then
        part.weather = {}
        if test(0, "-") then
          part.weather.intensity = "light"
          skip(1) -- -
        elseif test(0, "+") then
          part.weather.intensity = "heavy"
          skip(1) -- +
        else
          part.weather.intensity = "moderate"
        end
        if test(2, "%s", 1) then
          part.weather.code = substring(2)
        elseif test(3, "%s", 1) then
          part.weather.code = substring(3)
        else
          part.weather.code = substring(4)
        end
        skipWhitespaces()
      end
    end
    
    while (not test(0, "%d", 1)) and test(3, "%d", 1) and (nextGroupLength() == 6 or nextGroupLength() == 8 or nextGroupLength() == 9) do
      local cloud = {}
      cloud.cover = substring(3)
      cloud.height = substring(3).."00"
      if not test(0, "%s", 1) then
        if test(2, "%s", 1) then
          cloud.special = substring(2)
        else
          cloud.special = substring(3)
        end
      end
      if not part.clouds then
        part.clouds = {}
      end
      table.insert(part.clouds, cloud)
      skipWhitespaces()
    end
    
    -- temperature and dew point
    if test(2, "/") then
      part.temp = substring(2)
      skip(1) -- /
      part.dewPoint = substring(2)
      skip(1)
      skipWhitespaces()
    end
    
    -- QNH
    if test(0, "Q") then
      skip(1) -- Q
      part.qnh = substring(4)
      skipWhitespaces()
    end
    
    -- past weather
    if test(0, "RE") then
      part.weather.past = {}
      skip(2)
      if test(0, "-") then
        part.weather.past.intensity = "light"
        skip(1) -- -
      elseif test(0, "+") then
        part.weather.past.intensity = "heavy"
        skip(1) -- +
      else
        part.weather.past.intensity = "moderate"
      end
      if test(2, "%s", 1) then
        part.weather.past.code = substring(2)
      else
        part.weather.past.code = substring(4)
      end
      skipWhitespaces()
    end
    
    -- wind shear
    while test(0, "WS") do
      skip(2) -- WS
      skipWhitespaces()
      if test(0, "ALL") then
        part.wind.shear = {}
        part.wind.shear = true
        skip(3) -- ALL
        skipWhitespaces()
        skip(3) -- RWY
        skipWhitespaces()
        break
      else
        skip(3) -- RWY
        skipWhitespaces()
        local v = nil
        if test(2, "%s", 1) then
          v = substring(2)
        else
          v = substring(3)
        end
        if not part.wind.shear then
          if not part.wind then
            part.wind = {}
          end
          part.wind.shear = {}
        end
        table.insert(part.wind.shear, v)
        skipWhitespaces()
      end
    end
    
    -- trend
    if not report.trends then
      report.current = deepcopy(part)
    else
      table.insert(report.trends, deepcopy(part))
    end
    part = {}
    if test(0, "PROB") then
      print("PROB")
      skip(4) -- PROB
      part.probability = substring(2)
      print(part.probability)
      skipWhitespaces()
    end
    if not (test(0, "TEMPO") or test(0, "BECMG")) then
      break
    end
    if not report.trends then
      report.trends = {}
    end
    part.change = substring(5)
    skipWhitespaces()
  end
  
  -- trend is not implemented (whoever wants to do that: feel free ;) )
  
  return report
end

function reportToMessage(report)
  -- station
  local msg = "Station: "..report.station.."\n"
  -- time
  msg = msg.."Time: "..report.time.day.." day at "..report.time.hour..":"..report.time.minute.." UTC\n"
  -- loop through parts
  local i = 0
  while not report.trends or i <= #report.trends do
    -- get part
    local part = nil
    if i == 0 then
      part = report.current
      msg = msg.."Current conditions:\n"
    else
      part = report.trends[i]
      msg = msg..part.change.." from "..part.effective.from.day.."th day at "..part.effective.from.hour.." UTC to "..part.effective.to.day.."th day at "..part.effective.to.hour.." UTC:\n"
    end
    if part.probability then
      msg = msg.."  Probability: "..part.probability.."%\n"
    end
    
    -- print part
    if part.temp then
      msg = msg.."  Temperature: "..part.temp.."°C\n"
    end
    if part.dewPoint then
      msg = msg.."  Dew Point: "..part.dewPoint.."°C\n"
    end
    if part.qnh then
      msg = msg.."  QNH: "..part.qnh.."hPa\n"
    end
    if part.wind then
      msg = msg.."  Wind: "..part.wind.dir.."° with "..part.wind.force.."kt\n"
      if part.wind.gust then
        msg = msg.."  Max Gust: "..part.wind.gust.."kt\n"
      end
      if part.wind.drif then
        msg = msg.."  Wind Drift: "..part.wind.drift.min.."-"..part.wind.drift.max.."°\n"
      end
      if part.wind.shear then
        if next(part.wind.shear) then
          msg = msg.."  Wind Shear on Runway: "
          for _, v in pairs(part.wind.shear) do
            msg = msg..v..", "
          end
          msg = msg:sub(0, #msg - 2) -- remove last ,
          msg = msg.."\n"
        end
      end
    end
    if part.cavok then
      msg = msg.."  Clouds and Visibility OK (CAVOK)\n"
    end
    if part.visibility then
      if part.visibility.ground then
        if part.visibility.ground.min then
          msg = msg.."  "
          if part.visibility.ground.max then
            msg = msg.."Minimum "
          end
          msg = msg.."Ground Visibility: "..part.visibility.ground.min.length.."m"
          if part.visibility.ground.min.dir then
            msg = msg.." in direction "..part.visibility.ground.min.dir
          end
          msg = msg.."\n"
        end
        if part.visibility.ground.max then
          msg = msg.."  Maximum Ground Visibility: "..part.visibility.ground.max.length.."m"
          if part.visibility.ground.max.dir then
            msg = msg.." in direction "..part.visibility.ground.max.dir
          end
          msg = msg.."\n"
        end
      end
      if part.visibility.runway then
        if next(part.visibility.runway) then
          msg = msg.."  Runway Visbilities:\n"
        end
        for _, v in pairs(part.visibility.runway) do
          msg = msg.."    "..v.name..": "..v.dist.."m"
          if v.variation then
            msg = msg.." to "..v.variation.."m"
          end
          msg = msg.." and "..v.trend.."\n"
        end
      end
      if part.visibility.vertical then
        msg = msg.."  Vertical Visibility: "..part.visibility.vertical.."ft"
      end
    end
    if part.skyclear then
      msg = msg.."  Sky is clear\n"
    end
    if part.weather then
      msg = msg.."  Weather: "..part.weather.intensity.." "..part.weather.code.."\n"
    end
    if part.clouds then
      if next(part.clouds) then
        msg = msg.."  Clouds:\n"
        for _, v in pairs(part.clouds) do
          msg = msg.."    "..v.cover.." "
          if v.special then
            msg = msg..v.special.." "
          end
          msg = msg.."at "..v.height.."ft\n"
        end
      end
    end
    
    
    -- next part
    if not report.trends then
      break
    end
    i = i + 1
  end
  
  return msg
end

function getMetarTafMessage(station, showTaf)
  local m, t, e = getData(station, showTaf)
  if not m then
    return "Error: "..e
  end
  local msg = ""
  
  msg = msg.."Raw METAR:\n"..m.."\n"
  local metarReport = parseMetarOrTafReport(m)
  local metarMessage = reportToMessage(metarReport)
  msg = msg.."Report:\n"..metarMessage.."\n"
  
  if t then
    msg = msg.."\nRaw TAF:\n"..t.."\n"
    local tafReport = parseMetarOrTafReport(t)
    local tafMessage = reportToMessage(tafReport)
    msg = msg.."Report:\n"..tafMessage.."\n"
  end
  
  return msg
end

function run(msg, matches)
  local taf = false
  if matches[1]:sub(1, 10) == "!metar taf" then
    taf = true
  end
  local station = matches[1]:sub(#matches[1] - 3, #matches[1])
  local ret = getMetarTafMessage(station, taf)
  return ret
end

return {
  description = "Print METAR and optionally TAF", 
  usage = "!metar [taf] stationcode",
  patterns = {
    "^!metar %a%a%a%a$",
    "^!metar taf %a%a%a%a"
  }, 
  run = run 
}

end