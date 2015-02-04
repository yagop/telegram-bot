-- If you're "out" of an event!
-- Use !imout eventname

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


function leave_event(chat, text,user)
	eventname = string.match(text, "[!|.]imout (.+)")
	if (eventname == nil) then
		return "Usage: !imout eventname"
	end
	if _values[chat] == nil then
		_values[chat] = {}
	end
	if (eventname == nil) then
		return "Usage: !imout eventname"
	end
	
	eventname = string.lower(eventname)
	if _values[chat][eventname] == nil then
	  return "Event doesn't exists..."
	end
	
	_values[chat][eventname].attend[user] = false

	-- Save values to file
	serialize_to_file(_values, _file_values)

	
	return "["..eventname.."] "..user.." is out!"
end

function run(msg, matches)
	local chat_id = tostring(msg.to.id)
	local text = leave_event(chat_id, msg.text,get_name(msg))
	return text
end


return {
    description = "If you're 'out' of an event!", 
    usage = {
      "!imout [event name]"},
    patterns = {
      "^[!|.]imout (.+)$",
    }, 
    run = run 
}


