--[[ 
This mention notifier script will let your bot write a message to your private chat, if some keyword listed below is used, for example when someone uses your nickname or variations of it. 

(There is no case sensitivity. In the case you want to disable case insensitivity, just comment with "--" the line "local text = string.lower(msg.text)") 

Update 2015_06_16: 
- added a local enabled variable, in order to set it to 0, without having to delete the keywords, useful for temporary disable of that match.
- added empty nickname checking
- bug fixes

Update 2015_10_30:
Syntax

REMEMBER TO SET YOUR ID ON THE "LOCAL RECEIVERID" LINE, OTHERWISE YOU WON'T RECEIVE PM'S! 
 ]]--

local function run(msg)
	local text = string.lower(msg.text)
	local origin = get_receiver(msg)
	local chat_id = msg.to.id
	local chat_name = msg.to.print_name

	-- Empty user name check
	if not msg.from.username then
		from_username = "" .. msg.from.print_name
	else
		from_username = ('@' .. msg.from.username)
	end
	-- End of empty user name check
	-- Here you set up your keywords you want their use to be notified of.
	-- change the enabled var from 1 to 0 to disable a specific check
	if string.find(text, "keyword1") or string.find(text,"yourname") or string.find(text, "your nickname") then
		local enabled = "1"
			if string.find(enabled, "1") then 
				-- change user#idXXXXXX with the id of the user (supposedly to be yourself) where you want to be notified. 
				-- Also, you can change "user#idXXXXXX" to "chat#idXXXXX" if you want to receive the notification inside a group. 
				receiverid = 'user#idXXXXXXX'
				texttosend = "You got mentioned by  " .. from_username .." Chat_name:  " .. chat_name .. "Chat_id:  " .. chat_id
				do fwd_msg(receiverid, msg.id, ok_cb, false) end
				do send_msg(receiverid, texttosend, ok_cb, false)
				return 
				end
			end
	else
	return
	end 
end

return {
 description = "AlertMe",
 usage = "You get a PM if one of the keyword you set has been used",
 patterns = {
 "^(.+)$"
 }, 
 run = run 
}