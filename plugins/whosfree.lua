
function run(msg, matches)
   -- Do the request
   local res, code = https.request("http://www.rockym93.net/code/titp2/titp_now.py")
  if code == 200 then 
   return "Free now:\n"..res.."\n\n via TITP (rockym93.net)"
  end
end


return {
  description = "Who's currently free (via TITP (rockym93))",
  usage = "!whosfree",
  patterns = {
    "^!whosfree$",
    },
    run = run
  }

