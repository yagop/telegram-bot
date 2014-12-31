function update_user_stats(msg)
  -- Save user to _users table
  local from_id = tostring(msg.from.id)
  local to_id = tostring(msg.to.id)
  local user_name = get_name(msg)
  print ('New message from '..user_name..'['..to_id..']'..'['..from_id..']')
  -- If last name is nil dont save last_name.
  local user_last_name = msg.from.last_name
  local user_print_name = msg.from.print_name
  if _users[to_id] == nil then
    _users[to_id] = {}
  end
  if _users[to_id][from_id] == nil then
    _users[to_id][from_id] = {
      name = user_name,
      last_name = user_last_name,
      print_name = user_print_name,
      msg_num = 1
    }
  else
    local actual_num = _users[to_id][from_id].msg_num
    _users[to_id][from_id].msg_num = actual_num + 1
    -- And update last_name
    _users[to_id][from_id].last_name = user_last_name
  end
end

function load_user_stats()
  local f = io.open('res/users.json', "r+")
  -- If file doesn't exists
  if f == nil then
    f = io.open('res/users.json', "w+")
    f:write("{}") -- Write empty table
    f:close()
    return {}
  else
    local c = f:read "*a"
    f:close()
    return json:decode(c)
  end
end

function save_stats()
	-- Save stats to file
	local json_users = json:encode_pretty(_users)
	vardump(json_users)
	file_users = io.open ("./res/users.json", "w")
	file_users:write(json_users)
	file_users:close()
end

function get_stats_status( msg )
	-- vardump(_users)
	local text = ""
  	local to_id = tostring(msg.to.id)

	for id, user in pairs(_users[to_id]) do
		if user.last_name == nil then
			text = text..user.name.." ["..id.."]: "..user.msg_num.."\n"
		else
			text = text..user.name.." "..user.last_name.." ["..id.."]: "..user.msg_num.."\n"
		end
	end
	print("usuarios: "..text)
	return text
end

function run(msg, matches)
	-- TODO: I need to know wich patterns matches.
	if matches[1] == "!stats" then
		return get_stats_status(msg)
	else 
		print ("update stats")
		update_user_stats(msg)
	end
end

-- TODO: local vars
_users = load_user_stats()

return {
    description = "Numer of messages by user", 
    usage = "!stats",
    patterns = {
        ".*",
    	"^!stats"
    	}, 
    run = run 
}