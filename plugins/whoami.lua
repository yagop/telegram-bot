
function run(msg, matches)

  	if is_sudo(msg) then
		return get_receiver(msg)
	end
end

return {
    description = "Returns sender's id",
    usage = "!whoami",
    patterns = {"^!whoami$"}, 
    run = run 
}

