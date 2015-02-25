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


function save_event(chat, text )
	eventname = string.match(text, "[!|.]newevent (.+)")
	if (eventname == nil) then
		return "Usage: !newevent eventname"
	end
	if _values[chat] == nil then
		_values[chat] = {}
	end
	if (eventname == nil) then
		return "Usage: !newevent eventname"
	end
	
	eventname = string.lower(eventname)
	
	if _values[chat][eventname] then
	  return "Event already exists..."
	end
	
	_values[chat][eventname] = {}
	_values[chat][eventname].attend = {}
	_values[chat][eventname].place = ""
	_values[chat][eventname].what = ""
	_values[chat][eventname].when = ""

	-- Save values to file
	serialize_to_file(_values, _file_values)

	
	return "New event  "..eventname.." created!"
end

function run(msg, matches)
	local chat_id = tostring(msg.to.id)
	local text = save_event(chat_id, msg.text)
	return text
end


return {
    description = "Create a new event", 
    usage = {
      "!newevent [event name]"},
    patterns = {
      "^[!|.]newevent (.+)$",
    }, 
    run = run 
}

