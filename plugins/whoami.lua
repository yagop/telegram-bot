function run(msg, matches)

	return get_receiver(msg)
end

return {
    description = "Returns sender's or chat's id",
    usage = "!whoami",
    patterns = {"^!whoami$"}, 
    run = run 
}
