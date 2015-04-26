do

function getRandNum(lower, upper)
  num = math.random(lower, upper)
  return num
end

function getRandNumBounds(bounda, boundb)
  local na = tonumber(bounda)
  local nb = tonumber(boundb)
  local lower = math.min(na, nb)
  local upper = math.max(na, nb)
  num = getRandNum(lower, upper)
  return num
end

function run(msg, matches)
  if matches[1] == "!random" then
    return getRandNum(1, 6)
  end
  return getRandNum(matches[1], matches[2])
end

return {
    description = "random integer number between lower and upper", 
    usage = "!random [lower upper]",
    patterns = {
      "^!random$",
      "^!random ([0-9]+) ([0-9]+)$",
    }, 
    run = run 
}

end