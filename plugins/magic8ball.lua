do

function run(msg, matches)
  local answers = {'It is certain','It is decidedly so','Without a doubt',
                  'Yes definitely','You may rely on it','As I see it, yes',
                  'Most likely','Outlook good','Yes','Signs point to yes',
                  'Reply hazy try again','Ask again later',
                  'Better not tell you now','Cannot predict now',
                  'Concentrate and ask again','Don\'t count on it',
                  'My reply is no','My sources say no','Outlook not so good',
                  'Very doubtful'}
  return answers[math.random(#answers)]
end

return {
  description = "Magic 8Ball",
  usage = "!magic8ball",
  patterns = {"^!magic8ball$"},
  run = run
}

end
