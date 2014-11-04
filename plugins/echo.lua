
function run(msg, matches)
  return matches[1]
end

return {
    description = "echoes the msg", 
    usage = "!echo [whatever]",
    patterns = {"^!echo (.*)$"}, 
    run = run 
}

