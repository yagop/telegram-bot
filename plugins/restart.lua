
local function run(msg, matches)
  reload_bot()
end

return {
  description = "Restarts the bot",
  usage = "!restart",
  patterns = {
    "^!restart$"
  }, 
  run = run 
}
