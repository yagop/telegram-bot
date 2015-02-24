
function run(msg, matches)
   -- Do the request
   return "Working" 
end


return {
  description = "Who's currently free (via TITP (rockym93))",
  usage = "!whosfree",
  patterns = {
    "^!whosfree$",
    },
    run = run
  }

