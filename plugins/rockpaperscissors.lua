do

function run(msg, matches)
  local answers = {'Rock', 'Paper', 'Scissors'}
  return answers[math.random(#answers)]
end

return {
  description = "Settle Arguments",
  usage = "!rps",
  patterns = {"^!rps"},
  run = run
}

end
