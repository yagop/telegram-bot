-- End an event!
-- Use !endevent eventname

local _file_values = './data/events.lua'


function read_file_values( )
  local f = io.open(_file_values, "r+")
  -- If file doesn't exists
  if f == nil then
    -- Create a new empty table
    print ('Created value file '.._file_values)
    serialize_to_file({}, _file_values)
  else
    print ('Stats loaded: '.._file_values)
    f:close() 
  end
  return loadfile (_file_values)()
end

_values = read_file_values()


function end_event(chat, text )
	eventname = string.match(text, "[!|.]endevent (.+)")
	if (eventname == nil) then
		return "Usage: !endevent eventname"
	end
	if _values[chat] == nil then
		_values[chat] = {}
	end
	if (eventname == nil) then
		return "Usage: !endevent eventname"
	end

	if _values[chat][eventname] == nil then
	  return "Event doesn't exists..."
	end
	
	_values[chat][eventname] = nil

	-- Save values to file
	serialize_to_file(_values, _file_values)

	
	return "Event ["..eventname.."] ended!"
end

function run(msg, matches)
	local chat_id = tostring(msg.to.id)
	local text = end_event(chat_id, msg.text)
	return text
end


return {
    description = "End an event", 
    usage = {
      "!endevent [event name]"},
    patterns = {
      "^[!|.]endevent (.+)$",
    }, 
    run = run 
}

