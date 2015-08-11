-- data saved to moderation.json
-- check moderation plugin
do

local function create_group(msg)
    -- superuser and admins only (because sudo are always has privilege)
    if not is_admin(msg) then
        return "You're not admin!"
    end
    local group_creator = msg.from.print_name
    create_group_chat (group_creator, group_name, cb_extra, false)
	return 'Group '..string.gsub(group_name, '_', ' ')..' has been created.'
end

local function set_description(msg)
    if not is_momod(msg) then
        return "For moderators only!"
    end
    if not is_chat_msg(msg) then
        return "This is not a group chat."
    end
    local data = load_data(_config.moderation.data)
    local data_cat = 'description'
	if not data[tostring(msg.to.id)] then
		return 'Group is not added!. Please check moderation plugin.'
	end
	data[tostring(msg.to.id)][data_cat] = deskripsi
	save_data(_config.moderation.data, data)

	return 'Set group description to:\n'..deskripsi
end

local function get_description(msg)
    if not is_chat_msg(msg) then
        return "This is not a group chat."
    end
    local data_cat = 'description'
    local data = load_data(_config.moderation.data)
    if not data[tostring(msg.to.id)] then
		return 'Group is not added!. Please check moderation plugin.'
	end
    if not data[tostring(msg.to.id)][data_cat] then
		return 'No description available.'
	end
    local about = data[tostring(msg.to.id)][data_cat]
    local about = string.gsub(msg.to.print_name, "_", " ")..':\n\n'..about
    return 'About '..about
end

local function set_rules(msg)
    if not is_momod(msg) then
        return "For moderators only!"
    end
    if not is_chat_msg(msg) then
        return "This is not a group chat."
    end
    local data = load_data(_config.moderation.data)
    local data_cat = 'rules'
	if not data[tostring(msg.to.id)] then
		return 'Group is not added!. Please check moderation plugin.'
	end
	data[tostring(msg.to.id)][data_cat] = rules
	save_data(_config.moderation.data, data)

	return 'Set group rules to:\n'..rules
end

local function get_rules(msg)
    if not is_chat_msg(msg) then
        return "This is not a group chat."
    end
    local data_cat = 'rules'
    local data = load_data(_config.moderation.data)
    if not data[tostring(msg.to.id)] then
		return 'Group is not added!. Please check moderation plugin.'
	end
    if not data[tostring(msg.to.id)][data_cat] then
		return 'No rules available.'
	end
    local rules = data[tostring(msg.to.id)][data_cat]
    local rules = string.gsub(msg.to.print_name, '_', ' ')..' rules:\n\n'..rules
    return rules
end

function run(msg, matches)
    if matches[1] == 'creategroup' and matches[2] then
        group_name = matches[2]
        return create_group(msg)
    end
    if matches[1] == 'setabout' and matches[2] then
        deskripsi = matches[2]
        return set_description(msg)
    end
    if matches[1] == 'about' then
        return get_description(msg)
    end
    if matches[1] == 'setrules' then
        rules = matches[2]
        return set_rules(msg)
    end
    if matches[1] == 'rules' then
        return get_rules(msg)
    end
end


return {
  description = "Plugin to manage group chat.", 
  usage = {
    "!creategroup <group_name> : Create a new group",
    "!setabout <description> : Set group description",
    "!about : Read group description",
    "!setrules <rules> : Set group rules",
    "!rules : Read group rules",
    },
  patterns = {
    "^!(creategroup) (.*)$",
    "^!(setabout) (.*)$",
    "^!(about)$",
    "^!(setrules) (.*)$",
    "^!(rules)$",
  }, 
  run = run,
}

end
