-- See what's on (list events)
-- Use !whatson eventname

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


function list_events(chat, text )
	if _values[chat] == nil then
		_values[chat] = {}
	end
	local ret = "Events: \n"
	for event,users in pairs(_values[chat]) do
		ret = ret .. event .. " \n"
	end
	
	return ret
end

function run(msg, matches)
	local chat_id = tostring(msg.to.id)
	local text = list_events(chat_id, msg.text)
	return text
end


return {
    description = "See what's on! (Lists Events)", 
    usage = {
      "!whatson"},
    patterns = {
      "^!whatson$",
    }, 
    run = run 
}

