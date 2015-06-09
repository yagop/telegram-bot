local function run(msg, matches)
	local text = run_command('/opt/vc/bin/vcgencmd measure_temp') or 'An error happened'
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
