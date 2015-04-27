do

local socket = require("socket")
-- TODO: Timeout

function cron()
  -- Use yours desired web and id
  local addr = "www.google.com"
  local dest = "user#id"..our_id
  -- Checks a TCP connexion
  local connexion = socket.connect(addr, 80)
  if not connexion then 
    local text = "ALERT: "..addr.." is offline"
    print (text)
    send_msg(dest, text, ok_cb, false)
  else
    connexion:close()
  end
end

return {
  description = "If domain is offline, send msg to peer",
  usage = "",
  patterns = {},
  run = nil,
  cron = cron
}

end
