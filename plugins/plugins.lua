function enable_plugin( filename )
	-- Checks if file exists
	if file_exists('plugins/'..filename) then
		-- Add to the config table
		table.insert(config.enabled_plugins, filename)
		-- Reload the plugins
		reload_plugins( )
	else
		return 'Plugin does not exists'
	end
end

function reload_plugins( )
	plugins = {}
	load_plugins()
	return list_plugins(true)
end

function list_plugins(only_enabled)
	local text = ''
	for k, v in pairs( plugins_names( )) do
		--  ✔ enabled, ❌ disabled
		local status = '❌'
		-- Check if is enabled
		for k2, v2 in pairs(config.enabled_plugins) do
			if v == v2 then 
				status = '✔' 
			end
		end
		if not only_enabled or status == '✔' then
			text = text..v..' '..status..'\n'
		end
	end
	return text
end

function run(msg, matches)
	-- Show the available plugins 
	if matches[1] == '!plugins' then
		return list_plugins()
	end
	-- Reload all the plugins!
	if matches[1] == 'reload' then
		return reload_plugins(true)
	end
	-- Enable a plugin
	if matches[1] == 'enable' then
		print("enable: "..matches[2])
		return enable_plugin(matches[2])
	end
end

return {
	description = "Enable / Disable plugins", 
	usage = "!plugins",
	patterns = {
		"^!plugins$",
		"^!plugins (enable) ([%w%.]+)$",
		"^!plugins (reload)$"
		}, 
	run = run 
}