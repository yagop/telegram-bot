

function run(msg, matches)
  
  print("test")
  user = get_name(msg)
  local res, code = http.request("http://www.rockym93.net/code/titp2/titp_write_now.py?name="..user)

  if code == 200 then
    local res, code = http.request("http://www.rockym93.net/code/titp2/titp_now.py")
    if code==200 then
      text = user .. " is free for the hour!\n\nAlso (supposedly) free now:\n"..res .."\n\nvia TITP (rockym93.net)"
    end
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

