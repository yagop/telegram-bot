--[[
	binsh by NXij
	https://github.com/NXij/binsh/
	https://github.com/topkecleon/binsh/

	Shell output for telegram-bot.

	Warning: This plugin interfaces with your operating system. Even without root privileges, a bad command can be harmful.
]]--

do

	function run(msg, matches)
		return io.popen(matches[1]):read('*all')
	end

	return {
		description = 'Run a system command.',
		usage = {'!bin <command>'},
		patterns = {
			'^!bin (.*)$'
		},
		run = run,
		privileged = true
	}

end

