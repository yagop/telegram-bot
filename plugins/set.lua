function save_value( text )
	var_name, var_value = string.match(text, "(%a+) (.+)")
	if (var_name == nil or var_value == nil) then
		return "Usage: !set var_name value"
	end
	config.values[var_name] = var_value
	local json_text = json:encode_pretty(config) 
	file = io.open ("./bot/config.json", "w+")
	file:write(json_text)
	file:close()
	return "Saved "..var_name.." = "..var_value
end

function run(msg, matches)
	local text = save_value(msg.text)
	return text
end

return {
    description = "Set value", 
    usage = "!set [value_name] [data]",
    patterns = {"^!set (%a+) (.+)$"}, 
    run = run 
}

