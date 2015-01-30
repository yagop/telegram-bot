-- Create a new event!
-- Use !newevent eventname

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


function when_event(chat, text )
	eventname,when = string.match(text, "!setwhen (%S+) (.+)")
	if (eventname == nil) then
		return "Usage: !setwhen eventname when"
	end
	if _values[chat] == nil then
		_values[chat] = {}
	end
	if (when == nil) then
		return "Usage: !setwhen eventname when"
	end
	if _values[chat] == nil then
		_values[chat] = {}
	end
	if _values[chat][eventname] == nil then
	  return "Event doesn't exist..."
	end
	
	_values[chat][eventname].when = when 

	-- Save values to file
	serialize_to_file(_values, _file_values)

	
	return "["..eventname.."] Date Set!"
end

function run(msg, matches)
	local chat_id = tostring(msg.to.id)
	local text = when_event(chat_id, msg.text)
	return text
end


return {
    description = "Sent Event Location", 
    usage = {
      "!setwhen [event name] [when]"},
    patterns = {
      "^!setwhen (%S+) (.+)$",
    }, 
    run = run 
}


