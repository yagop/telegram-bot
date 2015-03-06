
function getBoobs()
	
	local rand = math.random(1, 8315)
	local res,status = http.request("http://api.oboobs.ru/boobs/get/"..rand)

	if status ~= 200 then return nil end

	local data = json:decode(res)

	-- The OpenBoobs API sometimes returns an empty array
	if not data[1] then 
		print 'Cannot get that boobs, trying another ones...'
		return getBoobs() 
	end

	return 'http://media.oboobs.ru/' .. data[1].preview
end

function run(msg, matches)

	local boobs = getBoobs()

	if boobs ~= nil then 
		file = download_to_file(boobs)
		send_photo(get_receiver(msg), file, ok_cb, false)
	else
		return 'Error getting boobs for you, please try again later.' 
	end
end

return {
    description = "Gets a random boobs pic", 
    usage = "!boobs",
    patterns = {
      "^!boobs$"
    }, 
    run = run 
}