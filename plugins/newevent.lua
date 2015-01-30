-- Create a new event!
-- Use !newevent eventname

local _file_values = './data/events.lua'

function save_value(chat, text )
	eventname = string.match(text, "!newevent (%a+)")
	if (eventname == nil) then
		return "Usage: !newevent eventname"
	end
	if _values[chat] == nil then
		_values[chat] = {}
	end

	
	return "New event  "..eventname.." created!"
end

function run(msg, matches)
	local chat_id = tostring(msg.to.id)
	local text = save_value(chat_id, msg.text)
	return text
end


return {
    description = "Create a new event", 
    usage = {
      "!newevent [event name]"},
    patterns = {
      "^!newevent (%a+)$",
    }, 
    run = run 
}

end
