
function run(msg, matches)
   -- Do the request
   print("test")
   local res, code = http.request("http://www.rockym93.net/code/titp2/timetable.json")
   print(res)
   print(code)
  if code == 200 then 
   local tt = JSON:decode(res) 
   tt.remove(0)
   text = "Today\n\n"
   for day,users in pairs(tt) then
      text = text .. day .. users.."\n"
   end
   return text
  end
end


return {
  description = "Who's  free today (via TITP (rockym93))",
  usage = "!free today",
  patterns = {
    "^[!|.]free today$",
    },
    run = run
  }

