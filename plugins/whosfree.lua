

function format_time(timestamp, format, tzoffset, tzname)
   if tzoffset == "local" then  -- calculate local time zone (for the server)
      local now = os.time()
      local local_t = os.date("*t", now)
      local utc_t = os.date("!*t", now)
      local delta = (local_t.hour - utc_t.hour)*60 + (local_t.min - utc_t.min)
      local h, m = math.modf( delta / 60)
      tzoffset = string.format("%+.4d", 100 * h + 60 * m)
   end
   tzoffset = tzoffset or "GMT"
   format = format:gsub("%%z", tzname or tzoffset)
   if tzoffset == "GMT" then
      tzoffset = "+0000"
   end
   tzoffset = tzoffset:gsub(":", "")

   local sign = 1
   if tzoffset:sub(1,1) == "-" then
      sign = -1
      tzoffset = tzoffset:sub(2)
   elseif tzoffset:sub(1,1) == "+" then
      tzoffset = tzoffset:sub(2)
   end
   tzoffset = sign * (tonumber(tzoffset:sub(1,2))*60 +
      tonumber(tzoffset:sub(3,4)))*60
   return os.date(format, timestamp + tzoffset)
end

function run(msg, matches)
   day = string.match(msg.text, "[!|.]whosfree (.+)")
   text = ""
   -- Do the request
   if day == nil then
      print("test")
      local res, code = http.request("http://www.rockym93.net/code/titp2/titp_now.py")
      print(res)
      print(code)
     if code == 200 then 
      text = text .. "Free now:\n"..res.."\n\n via TITP (rockym93.net)"
     end
     return text
   else
      print("test")
      local res, code = http.request("http://www.rockym93.net/code/titp2/timetable.json")
      print(res)
      print(code)
      if code == 200 then 
         JSON = assert(loadfile "libs/JSON.lua")()
         local tt = JSON:decode(res)
         if day == "today" or day == "Today" then
            day = format_time(os.time(), "%A", "+08:00")
         end
         tt["users"] = nil
         print(tt)
         text = day .. "\n"
         for d,hours in pairs(tt) do
            if d == day then
               print(d)
               for i=8,18 do
                  text = text..tostring(i) .. ": " .. table.concat(hours[tostring(i)], ", ") .. "\n"
               end
                text = text .. "\n via TITP (rockym93.net)"
            return text
            end
         end
      end
     
   end
end



return {
  description = "Who's currently free (via TITP (rockym93))",
  usage = "!whosfree",
  patterns = {
    "^[!|.]whosfree$",
    "^[!|.]whosfree (.+)$"
    },
    run = run
  }

