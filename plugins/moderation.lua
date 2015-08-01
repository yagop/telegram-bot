do

local function callback(extra, success, result)
  vardump(success)
  vardump(result)
end

local function user_print_name(user)
   if user.print_name then
      return user.print_name
   end
   local text = ''
   if user.first_name then
      text = user.last_name..' '
   end
   if user.lastname then
      text = text..user.last_name
   end
   return text
end

local function modadd(msg)
    local data = load_data(_config.moderation.data)

	--if not _config.moderation.admins[msg.from.id] then return end

	if data[tostring(msg.to.id)] then
		return 'Group is already added.'
	end

	data[tostring(msg.to.id)] = {}
	save_data(_config.moderation.data, data)

	return 'Group has been added.'
end

local function modrem(msg)
    local data = load_data(_config.moderation.data)
    local receiver = get_receiver(msg)
	--if not _config.moderation.admins[msg.from.id] then return end

	if not data[tostring(msg.to.id)] then
		return 'Group is not added.'
	end

	data[tostring(msg.to.id)] = nil
	save_data(_config.moderation.data, data)

	return 'Group has been removed'
end

local function promote(msg, member)
    local data = load_data(_config.moderation.data)

	--if not _config.moderation.admins[msg.from.id] then return end

	if not data[tostring(msg.to.id)] then
		return 'Group is not added.'
	end

	if data[tostring(msg.to.id)][tostring(member)] then
		return member..' is already a moderator.'
	end

	data[tostring(msg.to.id)][tostring(member)] = member
	save_data(_config.moderation.data, data)

	return '@'..member..' has been promoted.'
end

local function demote(msg, member)
    local data = load_data(_config.moderation.data)

	--if not config.moderation.admins[msg.from.id] then return end

	if not data[tostring(msg.to.id)] then
		return 'Group is not added.'
	end

	if not data[tostring(msg.to.id)][tostring(member)] then
		return member..' is not a moderator.'
	end

	data[tostring(msg.to.id)][tostring(member)] = nil
	save_data(_config.moderation.data, data)

	return '@'..member..' has been demoted.'
end

local function modlist(msg)
    local data = load_data(_config.moderation.data)

	if not data[tostring(msg.to.id)] then
		return 'Group is not added.'
	end

	local message = 'List of moderators for ' .. msg.to.print_name .. ':\n'

	for k,v in pairs(data[tostring(msg.to.id)]) do
		--message = message .. v .. ' (' .. k .. ')\n'
		message = message .. v .. ' \n'
	end

	return message
end
	
function run(msg, matches)
  if msg.to.type == 'user' then
    return "Only works on group"
  end
  if matches[1] == 'modadd' then
    print("group "..msg.to.print_name.."("..msg.to.id..") added")
    vardump(msg)
    return modadd(msg)
  end
  if matches[1] == 'modrem' then
    print("group "..msg.to.print_name.."("..msg.to.id..") removed")
    return modrem(msg)
  end
  if matches[1] == 'promote' and matches[2] then
    local member = string.gsub(matches[2], "@", "")
    print("User "..member.." has been promoted")
    return promote(msg, member)
  end
  if matches[1] == 'demote' and matches[2] then
    local member = string.gsub(matches[2], "@", "")
    print("user "..member.." has been demoted")
    return demote(msg, member)
  end
  if matches[1] == 'modlist' then
    print(modlist)
    return modlist(msg)
  end
end


return {
  description = "Moderation plugin", 
  usage = {
    "!modadd : add group to moderation list",
    "!modrem : remove group from moderation list",
    "!promote <@username> : promote user as moderator",
    "!demote <@username> : demote user from moderator",
    "!modlist : list of moderators",
    },
  patterns = {
    "^!(modadd)$",
    "^!(modrem)$",
    "^!(promote) (.*)$",
    "^!(demote) (.*)$",
    "^!(modlist)$",
  }, 
  run = run,
  privileged = true
}

end
