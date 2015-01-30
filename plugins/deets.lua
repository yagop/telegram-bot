-- Event Details!
-- Use !deets eventname

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


function details_event(chat, text)
	eventname = string.match(text, "!whosin (.+)")
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
  ret = ret .. "When: " .. _values[chat][eventname].when .."\n"
  ret = ret .. "Place: ".._values[chat][eventname].place.."\n"
  ret = ret .. "\n\nIN:\n"
	for user,t in pairs(_values[chat][eventname].attend) do
	  if t == true then
	    ret = ret .. " -".. user .. " \n"
	   end
	end
	ret = ret .. "\n\nOUT:\n"
	for user,t in pairs(_values[chat][eventname].attend) do
	  if t == false then
	    ret = ret .. " -".. user .. " \n"
	   end
	end

	return ret
end

function run(msg, matches)
	local chat_id = tostring(msg.to.id)
	local text = details_event(chat_id, msg.text)
	return text
end


return {
    description = "Event Details", 
    usage = {
      "!deets [event name]"},
    patterns = {
      "^!deets (.+)$",
    }, 
    run = run 
}
