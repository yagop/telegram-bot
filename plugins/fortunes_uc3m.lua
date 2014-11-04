  
function get_fortunes_uc3m()
   math.randomseed(os.time())
   local i = math.random(0,178) -- max 178
   local web = "http://www.gul.es/fortunes/f"..i 
   b, c, h = http.request(web)
   return b
end


function run(msg, matches)
  return get_fortunes_uc3m()
end

return {
    description = "Fortunes from Universidad Carlos III", 
    usage = "!uc3m",
    patterns = {"^!uc3m$"}, 
    run = run 
}

