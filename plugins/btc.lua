
function getBTCEUR(eur)
   -- Do request on bitcoinaverage, the final / is critical!
   local res,code  = https.request("https://api.bitcoinaverage.com/ticker/global/EUR/")
   
   if code~= 200 then return nil end
   local data = json:decode(res)
     
   -- Easy, it's right there
   text = "BTC/EUR"..'\n'..'Buy: '..data.ask..'\n'..'Sell: '..data.bid
   
   -- If we have a number as second parameter, calculate the bitcoin amount
   if eur~=nil then
      btc = tonumber(eur) / tonumber(data.ask)
      text = text.."\n EUR "..eur.." = BTC "..btc
   end
   return text
end

function run(msg, matches)
  if matches[1] == "!btc" then
    return getBTCEUR(nil)
  end
  return getBTCEUR(matches[1])
end

return {
    description = "BTCEUR market value", 
    usage = "!btc [EUR]",
    patterns = {
      "^!btc$",
      "^!btc (%d+[%d%.]*)$",
    }, 
    run = run 
}

