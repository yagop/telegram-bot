

function run(msg, matches)
  
  print("test")
  user = get_name(msg)
  local res, code = http.request("http://www.rockym93.net/code/titp2/titp_write_now.py?name="..user)

  if code == 200 then 
    text = user .. "is free for the hour!\n\n via TITP (rockym93.net)"
  end
  return text

end



return {
  description = "Announce that you are free for the hour (via TITP (rockym93))",
  usage = "!imfree",
  patterns = {
    "^[!|.]imfree",
    },
    run = run
  }

