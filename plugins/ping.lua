socket = require("socket")

function cron()
	-- Checks a TCP connexion
	-- Use yours desired web and id
	local addr = "your.web.site"
	local dest = "user#id"..our_id 
    if not socket.connect(addr, 80) then 
    	local text = "ALERT: "..addr.." is offline"
    	print (text)
    	send_msg(dest, text, ok_cb, false)
    end
end

return {
    description = "If domain is offline, send msg to peer",
    usage = "",
    patterns = {},
    run = nil,
    cron = cron
}
