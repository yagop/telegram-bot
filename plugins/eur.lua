do

function getEURUSD(usd)
  local b = http.request("http://webrates.truefx.com/rates/connect.html?c=EUR/USD&f=csv&s=n")
  local rates = b:split(", ")
  local symbol = rates[1]
  local timestamp = rates[2]
  local sell = rates[3]..rates[4]
  local buy = rates[5]..rates[6] 
  text = symbol..'\n'..'Buy: '..buy..'\n'..'Sell: '..sell
  if usd then
    eur = tonumber(usd) / tonumber(buy)
    text = text.."\n "..usd.."USD = "..eur.."EUR"
  end
  return text
end

function run(msg, matches)
  if matches[1] == "!eur" then
    return getEURUSD(nil)
  end
  return getEURUSD(matches[1])
end

return {
    description = "EURUSD market value", 
    usage = "!eur [USD]",
    patterns = {
      "^!eur$",
      "^!eur (%d+[%d%.]*)$",
    }, 
    run = run 
}

end