local _file_values = './data/values.lua'

function save_value(chat, text )
	var_name, var_value = string.match(text, "!set (%a+) (.+)")
	if (var_name == nil or var_value == nil) then
		return "Usage: !set var_name value"
	end
	if _values[chat] == nil then
		_values[chat] = {}
	end
	_values[chat][var_name] = var_value

	-- Save values to file
	serialize_to_file(_values, _file_values)
	
	return "Saved "..var_name.." = "..var_value
end

function run(msg, matches)
	local chat_id = tostring(msg.to.id)
	local text = save_value(chat_id, msg.text)
	return text
end

return {
    description = "Set value", 
    usage = "!set [value_name] [data]",
    patterns = {"^!set (%a+) (.+)$"}, 
    run = run 
}

