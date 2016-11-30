function run(msg, matches)
  
  	local file = '/home/curr-bot/print'
  	fh = io.open(file, "r")

  	local content = ''

	while true do
	        local line = fh.read(fh)
	        if not line then break end
	        content = content .. line .. "\n"
	end

	io.close(fh)

  	return content
end

return {
  description = "Prints current UAH currencies.",
  usage = "!curr: prints current UAH currencies.",
  patterns = {
    "^!curr$"
  },
  run = run
}
