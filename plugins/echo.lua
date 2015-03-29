
function run(msg, matches)

	local count = tonumber(matches[1])
	local result = ""

	while (count > 0 ) do
		result = result .. matches[2] .. "\n"
		count = count - 1
		print (result)
	end

  	return result
end

return {
    description = "Simplest plugin ever!",
    usage = "!echo [count] [whatever]: echoes the msg N times",
    patterns = {"^!echo (%d) (.*)$"}, 
    run = run 
}

