
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
   end
   if day == "today" or day == "Today" then
      print("test")
      local res, code = http.request("http://www.rockym93.net/code/titp2/timetable.json")
      print(res)
      print(code)
      if code == 200 then 
         JSON = assert(loadfile "libs/JSON.lua")()
         local tt = JSON:decode(res)
         today = "Tuesday"
         tt[users] = nil
         print(tt)
         text = "Today\n\n"
         for day,hours in pairs(tt) do
            if day == today then
               for hour, users in pairs(hours) do
                  text = text .. hour
                  for user in users do
                     text = text .. user .. " "
                  end
                  text = text .. "\n"
               end
            end
         end
      end
         
      return text
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

