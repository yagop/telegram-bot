do

function run(msg, matches)
  return "Hello, " .. matches[1]
end

return {
  description = "Says hello to someone", 
  usage = "say hello to [name]",
  patterns = {
    "^say hello to (.*)$",
    "^Say hello to (.*)$"
  }, 
  run = run 
}

end