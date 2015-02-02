

function run(msg, matches)
   limit = string.match(msg.text, "!ratelimit (%d+)")
   ratelimit = limit
   return "Ratelimit set: "..limit.."s"
end

return {
    description = "set rate limit for img and gif", 
    usage = "!ratelimit seconds",
    patterns = {"^!ratelimit (%d+)$"}, 
    run = run 
}


