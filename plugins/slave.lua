require("./bot/utils")

do

function run(msg, matches)
  local url = nil
  
  if is_sudo(msg) then
    return 'Только не по ебалу, хозяин...' 
  end
end

return {
  description = "", 
  usage = {
  },
  patterns = {
    "^Раб.*хуёвый.*",
    "^раб.*хуёвый.*",

    "^Раб.*завали.*",
    "^раб.*завали.*",

    "^Раб.*ахуел.*",
    "^раб.*ахуел.*",

    "^Раб.*мудила.*",
    "^раб.*мудила.*",

    "^Раб.*уебок.*",
    "^раб.*уебок.*",
    "^[Рр]аб$"
  }, 
  run = run 
}

end
