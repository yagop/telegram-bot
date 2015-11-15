do

function run(msg, matches)
  return 'Merbot '.. VERSION .. [[ 
  Checkout http://git.io/v4Oi0
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
