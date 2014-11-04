
function run(msg, matches)
  local ret = ""
  for k, dict in pairs(plugins) do
    ret = ret .. dict.usage .. " -> " .. dict.description .. "\n"
  end
  return ret
end

return {
    description = "Lists all available commands", 
    usage = "help",
    regexp = "^help$", 
    run = run 
}

