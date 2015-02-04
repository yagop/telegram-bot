-- See who's in an event!
-- Use !whosin eventname

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


function whosin_event(chat, text)
	eventname = string.match(text, "[!|.]whosin (.+)")
	if (eventname == nil) then
		return "Usage: !whosin eventname"
	end
	if _values[chat] == nil then
		_values[chat] = {}
	end
	if (eventname == nil) then
		return "Usage: !whosin eventname"
	end

	if _values[chat][eventname] == nil then
	  return "Event doesn't exists..."
	end

  	local ret = "["..eventname.."] \n"
	for user,t in pairs(_values[chat][eventname].attend) do
	  if t == true then
	    ret = ret .. " -".. user .. " \n"
	   end
	end

	return ret
end

function run(msg, matches)
	local chat_id = tostring(msg.to.id)
	local text = whosin_event(chat_id, msg.text)
	return text
end


return {
    description = "See who's in an event", 
    usage = {
      "!whosin [event name]"},
    patterns = {
      "^[!|.]whosin (.+)$",
    }, 
    run = run 
}
