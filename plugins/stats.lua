function run(msg, matches)
	vardump(_users)
	-- Save stats to file
	local json_users = json:encode_pretty(_users)
	vardump(json_users)
	file_users = io.open ("./res/users.json", "w")
	file_users:write(json_users)
	file_users:close()

	local text = ""
  	local to_id = tostring(msg.to.id)

	for id, user in pairs(_users[to_id]) do
		if user.last_name == nil then
			text = text..user.name.." ["..id.."]: "..user.msg_num.."\n"
		else
			text = text..user.name.." "..user.last_name.." ["..id.."]: "..user.msg_num.."\n"
		end
	end
	return text
end

return {
    description = "Numer of messages by user", 
    usage = "!stats",
    patterns = {"^!stats"}, 
    run = run 
}