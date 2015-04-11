
function run(msg, matches)
  -- Convert expression to a function and execute it
  local expression = string.gsub(matches[1], "(%a+)", "math.%1")
  return load('return '..expression)()
end

return {
  description = "A simple calculator plugin.",
  usage = "!calc [expression]: calculates the mathematical expression",
  patterns = {
    "^!calc (.*)$"
  },
  run = run
}
