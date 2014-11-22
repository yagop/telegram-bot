
function run(msg, matches)
  local ret = ""
  for k, dict in pairs(plugins) do
  	if dict.usage ~= "" then
    	ret = ret .. dict.usage .. " -> " .. dict.description .. "\n"
	end
  end
  return ret
end

return {
    description = "Lists all available commands", 
    usage = "!help",
    patterns = {"^!help$"}, 
    run = run 
}