
function run(msg, matches)
  return 'Telegram Bot '.. VERSION .. [[ 
  Checkout http://git.io/FXGl
  Forked from @yagop 
  GNU v2 license.]]
end

return {
    description = "Shows bot version", 
    usage = "!version",
    patterns = {"^!version$"}, 
    run = run 
}

