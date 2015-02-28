local knownUsers = nil
local lastDate = nil

function run(msg, matches)
  local date = os.date("*t")
  --print(date)
  --print(lastDate)
  if date.hour >= 2 and date.hour <= 11 then
    if lastDate == nil then
      --print("lastDate nil")
      lastDate = date
      knownUsers = {}
    elseif lastDate.day ~= date.day or lastDate.month ~= date.month or lastDate.year ~= date.year then
      --print("lastDate different")
      lastDate = date
      knownUsers = {}
    end
    if knownUsers[msg.from.id] == nil then
      knownUsers[msg.from.id] = 1
      local username = msg.from.first_name or ""
      if date.hour >= 2 and date.hour < 4 then
        return "Ähm, hast du überhaupt geschlafen, " .. username .. "?"
      elseif date.hour >= 4 and date.hour < 6 then
        return "Guten Morgen " .. username .. ", du Frühaufsteher!"
      else
        return "Guten Morgen " .. username .. "!"
      end
    end
  end
end

return {
    description = "replies to messages in the morning", 
    usage = "send a message between 2 and 10 o'clock am",
    patterns = {"(.*)"}, 
    run = run 
}

