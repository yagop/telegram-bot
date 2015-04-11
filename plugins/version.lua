do

function run(msg, matches)
  return 'Telegram Bot '.. VERSION .. [[ 
  Checkout http://git.io/6jdjGg
  GNU GPL v2 license.]]
end

return {
  description = "Shows bot version", 
  usage = "!version: Shows bot version",
  patterns = {
    "^!version$"
  }, 
  run = run 
}

end
