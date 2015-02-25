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


function place_event(chat, text )
	eventname,what = string.match(text, "!setwhat (%S+) (.+)")
	if (eventname == nil) then
		return "Usage: !setwhat eventname description"
	end
	if _values[chat] == nil then
		_values[chat] = {}
	end
	if (place == nil) then
		return "Usage: !setwhat eventname description"
	end
	if _values[chat] == nil then
		_values[chat] = {}
	end
	if _values[chat][eventname] == nil then
	  return "Event doesn't exist..."
	end
	
	_values[chat][eventname].what = what 

	-- Save values to file
	serialize_to_file(_values, _file_values)

	
	return "["..eventname.."] description set!"
end

function run(msg, matches)
	local chat_id = tostring(msg.to.id)
	local text = place_event(chat_id, msg.text)
	return text
end


return {
    description = "Set Event Description", 
    usage = {
      "!setwhat [event name] [description]"},
    patterns = {
      "^!setwhat (%S+) (.+)$",
    }, 
    run = run 
}


