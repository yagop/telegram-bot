
function whosfree()
  -- Do the request
  local res, code = https.request(http://www.rockym93.net/code/titp2/titp_now.py)
  if code ~=200 then return "An error occured" end
  return "Free now:\n"..res.."\n\n via TITP (rockym93.net)"
end


function run(msg, matches)
  return whosfree()
end


return {
  description = "Who's currently free (via TITP (rockym93))",
  usage = "!whosfree",
  patterns = {
    "^[.|!]whosfree$",
    },
    run = run
  }

