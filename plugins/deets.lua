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


function details_event(chat, text,rec)
	eventname = string.match(text, "[!|.]deets (.+)")
	if (eventname == nil) then
		return "Usage: !deets eventname"
	end
	if _values[chat] == nil then
		_values[chat] = {}
	end
	if (eventname == nil) then
		return "Usage: !deets eventname"
	end

	if _values[chat][eventname] == nil then
	  return "Event doesn't exists..."
	end

  	local ret = "["..eventname.."] \n"
  	ret = ret .. "What: " .. _values[chat][eventname].what .."\n"
	ret = ret .. "When: " .. _values[chat][eventname].when .."\n"
  	ret = ret .. "Where: ".._values[chat][eventname].place.."\n"
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
	
	if _values[chat][eventname].place ~= "" then
		local location = _values[chat][eventname].place
		if _values[chat][eventname].place == "fun house" or _values[chat][eventname].place == "funhouse" then
			_values[chat][eventname].place = "12 asquith st mt claremont"
		end
		if location == "Food Party House" or location == "food party house" or location == "FPH" or location == "fph" then
			location = "50 McDonald St, Como"
		end
		local receiver	= rec
		local lat,lng,url	= get_staticmap(location)
		local file_path      = download_to_file(url)
		-- Send the actual location, is a google maps link
		send_location(receiver, lat, lng, ok_cb, false)
	  
		delay_s(2)
	   
		-- Clean up after some time
		postpone(rmtmp_cb, file_path, 20.0)
	end

	return ret
end


api_key = nil

base_api = "https://maps.googleapis.com/maps/api"

function delay_s(delay)
   delay = delay or 1
   local time_to = os.time() + delay
   while os.time() < time_to do end
end

function get_staticmap(area)
   local api        = base_api .. "/staticmap?"

   -- Get a sense of scale
   lat,lng,acc,types = get_latlong(area)
   
   local scale=types[1]
   if     scale=="locality" then zoom=8
   elseif scale=="country"  then zoom=4
   else zoom=13 end
      
   local parameters =
      "size=600x300" ..
      "&zoom="  .. zoom ..
      "&center=" .. URL.escape(area) ..
      "&markers=color:red"..URL.escape("|"..area)
   
   if api_key ~=nil and api_key ~= "" then
      parameters = parameters .. "&key="..api_key
   end
   return lat, lng, api..parameters
end


function run(msg, matches)
	local chat_id = tostring(msg.to.id)
	local text = details_event(chat_id, msg.text,get_receiver(msg))
	
	return text
end


return {
    description = "Event Details", 
    usage = {
      "!deets [event name]"},
    patterns = {
      "^[!|.]deets (.+)$",
    }, 
    run = run 
}
