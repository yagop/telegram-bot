local function run(msg, matches)
	local handle = io.popen("temperatura")
	local text = handle:read("*a")
	handle:close()

	return text
end

return{
	description = "Simple plugin that shows Raspberry Pi temperature!",
	usage = "!temperatura echoes the actual temperature.",
	patterns = {
		"^!temperatura (.*)$"
	},
	run = run
}
