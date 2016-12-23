do

function run(msg, matches)
	local choices = {'Piedra','Papel','Tijeras','Lagarto','Spock'}
	return choices[math.random(#choices)]
end

return {
	description = "Rock, Paper, Scissors!",
	usage = "!rps",
	patterns = {"^!rps ([Pp]iedra)$",
				"^!rps ([Pp]apel)$",
				"^!rps ([Tt]ijera)$",
				"^!rps ([Ll]agarto)$",
				"^!rps ([Ss]pock)$"},
	run = run
}

end