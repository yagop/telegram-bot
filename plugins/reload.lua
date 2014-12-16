
function run(msg, matches)
  load_plugins()
  return 'Plugins reloaded'
end

return {
    description = "Reloads bot plugins", 
    usage = "!reload",
    patterns = {"^!reload$"}, 
    run = run 
}

