--~ Reduces echoes to 1 loop (flood with many bots)

local function run(msg, matches)
    if matches[1]:starts("!echo ") then
        matches[1] = string.gsub(matches[1], "!echo", "")
    end
    vardump(matches[1])
    return matches[1]
end

return {
  description = "Makes the bot speak",
  usage = "!echo [whatever]: Tells the bot what to say",
  patterns = {
    "^!echo (.*)$"
  }, 
  run = run 
}
