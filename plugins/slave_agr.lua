require("./bot/utils")

do

function run(msg, matches)
  local url = nil
  
  if is_sudo(msg) then
    return "@vatobot больно пиздит" .. matches[1] .. " дрючком."
  end
end

return {
  description = "", 
  usage = {
  },
  patterns = {
    "^Раб.*пиздани.*( .*)$",
    "^раб.*пиздани.*( .*)$",

    "^Раб.*хуяни.*( .*)$",
    "^раб.*хуяни.*( .*)$",

    "^Раб.*побей.*( .*)$",
    "^раб.*побей.*( .*)$",

    "^Раб.*карай.*( .*)$",
    "^раб.*карай.*( .*)$",

    "^Раб.*накажи.*( .*)$",
    "^раб.*накажи.*( .*)$"
  }, 
  run = run 
}

end
