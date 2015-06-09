local function run(msg, matches)
	local handle = io.popen('/opt/vc/bin/vcgencmd measure_temp')
	local text = handle:read("*a")
	handle:close()

	return text
end

return{
	description = "Simple plugin that shows Raspberry Pi temperature!",
	usage = "!temp echoes the actual temperature.",
	patterns = {
		"^!([Tt]emp)$"
	},
	run = run
}
