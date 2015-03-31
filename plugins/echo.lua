
function run(msg, matches)
  return matches[1]
end

return {
  description = "Simplest plugin ever!",
  usage = "!echo [whatever]: echoes the msg",
  patterns = {
    "^!echo (.*)$"
  }, 
  run = run 
}
