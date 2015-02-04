-- Join an event!
-- Use !imin eventname

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


function join_event(chat, text,user)
	eventname = string.match(text, "[!|.]imin (.+)")
	if (eventname == nil) then
		return "Usage: !imin eventname"
	end
	if _values[chat] == nil then
		_values[chat] = {}
	end
	if (eventname == nil) then
		return "Usage: !imin eventname"
	end
	
	eventname = string.lower(eventname)

	if _values[chat][eventname] == nil then
	  return "Event doesn't exists..."
	end
	
	_values[chat][eventname].attend[user] = true

	-- Save values to file
	serialize_to_file(_values, _file_values)

	
	return "["..eventname.."] "..user.." is in!"
end

function run(msg, matches)
	local chat_id = tostring(msg.to.id)
	local text = join_event(chat_id, msg.text,get_name(msg))
	return text
end


return {
    description = "Join an event", 
    usage = {
      "!imin [event name]"},
    patterns = {
      "^[!|.]imin (.+)$",
    }, 
    run = run 
}


