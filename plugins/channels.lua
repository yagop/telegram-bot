function enable_channel( channel_id, channel_name )
	-- Add to the config table
	table.remove(_config.disabled_channels, get_index(channel_id))
	save_config()
	return "Channel "..channel_name.." enabled"
end

function disable_channel( channel_id, channel_name )
	-- Disable
	table.insert(_config.disabled_channels, channel_id)
	save_config( )
	return "Channel "..channel_name.." disabled"
end

function get_index( channel_id )
	for k,v in pairs(_config.disabled_channels) do
		if channel_id == v then
			return k
		end
	end
	-- If not found
	return false
end

function run(msg, matches)
	-- Enable a channel
	if matches[1] == 'enable' then
		print("enable: "..msg.to.id)
		return enable_channel(msg.to.id, msg.to.title)
	end
	-- Disable a channel
	if matches[1] == 'disable' then
		print("disable: "..msg.to.id)
		return disable_channel(msg.to.id, msg.to.title)
	end
end

return {
	description = "Plugin to manage channels. Enable or disable channel.", 
	usage = {
		"!channel enable: enable current channel",
		"!channel disable: disable current channel" },
	patterns = {
		"^!channel? (enable)",
		"^!channel? (disable)" }, 
	run = run,
	privileged = true
}