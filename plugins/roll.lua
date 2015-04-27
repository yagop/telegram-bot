do

local ROLL_USAGE = "!roll d<sides>|<count> d<sides>"
local DEFAULT_SIDES = 100
local DEFAULT_NUMBER_OF_DICE = 1
local MAX_NUMBER_OF_DICE = 100

function run(msg, matches)
  local str = matches[1]
  local sides = DEFAULT_SIDES
  local number_of_dice = DEFAULT_NUMBER_OF_DICE

  if str:find("!roll%s+d%d+%s*$") then
    sides = tonumber(str:match("[^d]%d+%s*$"))
  elseif str:find("!roll%s+%d+d%d+%s*$") then
    number_of_dice = tonumber(str:match("%s+%d+"))
    sides = tonumber(str:match("%d+%s*$"))
  end

  if number_of_dice > MAX_NUMBER_OF_DICE then
    number_of_dice = MAX_NUMBER_OF_DICE
  end

  local padding = #string.format("%d", sides)
  local results = ""

  local fmt = "%s %0"..padding.."d"
  for i=1,number_of_dice do
    results = string.format(fmt, results, math.random(sides))
  end

  return string.format("Rolling %dd%d:\n%s", number_of_dice, sides, results)
end

return {
  description = "Roll some dice!",
  usage = ROLL_USAGE,
  patterns = {
    "^!roll%s*.*"
  },
  run = run
}

end
