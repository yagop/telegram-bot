function run(msg, matches)
	local text = ""
	for id, user in pairs(_users) do
		text = text..user.name..": "..user.msg_num.."\n"
	end
	return text
end

return {
    description = "Numer of messages by user", 
    usage = "!stats",
    patterns = {"^!stats"}, 
    run = run 
}