do

local function modadd(msg)
    -- superuser and admins only (because sudo are always has privilege)
    if not is_admin(msg) then
        return "You're not admin"
    end
    local data = load_data(_config.moderation.data)
	if data[tostring(msg.to.id)] then
		return 'Group is already added.'
	end

	data[tostring(msg.to.id)] = {}
	save_data(_config.moderation.data, data)

	return 'Group has been added.'
end

local function modrem(msg)
    -- superuser and admins only (because sudo are always has privilege)
    if not is_admin(msg) then
        return "You're not admin"
    end
    local data = load_data(_config.moderation.data)
    local receiver = get_receiver(msg)
	if not data[tostring(msg.to.id)] then
		return 'Group is not added.'
	end

	data[tostring(msg.to.id)] = nil
	save_data(_config.moderation.data, data)

	return 'Group has been removed'
end

local function promote(msg, member)
    local data = load_data(_config.moderation.data)
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

	local message = 'List of moderators for ' .. string.gsub(msg.to.print_name, '_', ' ') .. ':\n'
	for k,v in pairs(data[tostring(msg.to.id)]) do
		message = message .. '- ' .. v .. ' \n'
	end

	return message
end
	
local function admin_promote(msg, admin_id)	
	if not is_sudo(msg) then
        return "Access denied!"
    end
	local data = load_data(_config.moderation.data)
	local admins = 'admins'
	if not data[tostring(admins)] then
		data[tostring(admins)] = {}
		save_data(_config.moderation.data, data)
	end

	if data[tostring(admins)][tostring(admin_id)] then
		return admin_name..' is already an admin.'
	end

	data[tostring(admins)][tostring(admin_id)] = admin_id -- admin_id kedua harusnya nama
	save_data(_config.moderation.data, data)

	return admin_id..' has been promoted as admin.'
end

local function admin_demote(msg, admin_id)
    if not is_sudo(msg) then
        return "Access denied!"
    end
    local data = load_data(_config.moderation.data)
	local admins = 'admins'
	if not data[tostring(admins)] then
		data[tostring(admins)] = {}
		save_data(_config.moderation.data, data)
	end

	if not data[tostring(admins)][tostring(admin_id)] then
		return admin_id..' is not an admin.'
	end

	data[tostring(admins)][tostring(admin_id)] = nil
	save_data(_config.moderation.data, data)

	return admin_id..' has been demoted from admin.'
end

local function admin_list(msg)
    local data = load_data(_config.moderation.data)
	local admins = 'admins'
	if not data[tostring(admins)] then
		data[tostring(admins)] = {}
		save_data(_config.moderation.data, data)
	end

	local message = 'List for Bot admins:\n'
	for k,v in pairs(data[tostring(admins)]) do
	    --message = message .. '- ' .. k .. v .. ' \n'
		message = message .. '- ' .. v .. ' \n'
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
    return modlist(msg)
  end
  if matches[1] == 'adminprom' then
    local admin_id = matches[2]
    print("user "..admin_id.." has been promoted as admin")
    return admin_promote(msg, admin_id)
  end
  if matches[1] == 'admindem' then
    local admin_id = matches[2]
    print("user "..admin_id.." has been demoted from admin")
    return admin_demote(msg, admin_id)
  end
  if matches[1] == 'adminlist' then
    return admin_list(msg)
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
    "^!(adminprom) (%d+)$", -- sudoer only
    "^!(admindem) (%d+)$", -- sudoers only
    "^!(adminlist)$",
  }, 
  run = run,
  moderated = true
}

end
