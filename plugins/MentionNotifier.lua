--[[ 
This mention notifier script will let your bot write a message to your private chat, if some keyword listed below is used, for example when someone uses your nickname or variations of it. 

(There is no case sensitivity. In the case you want to disable case insensitivity, just comment with "--" the line "local text = string.lower(msg.text)") 

Update 2015_06_16: 
- added a local enabled variable, in order to set it to 0, without having to delete the keywords, useful for temporary disable of that match.
- added empty nickname checking
- bug fixes

REMEMBER TO SET YOUR ID ON THE "LOCAL RECEIVERID" LINE, OTHERWISE YOU WON'T RECEIVE PM'S! 
 ]]--

local function run(msg)
local text = string.lower(msg.text) -- Disable this for case sensitivity
local origin = get_receiver(msg)
local chat_id = msg.to.id
local chat_name = msg.to.print_name
local receiverid = 'user#id00000000' -- YOUR ID user#id00000000

-- Empty user name check
if not msg.from.username then
from_username = "" 
else
from_username = ('@' .. msg.from.username)
end
-- End of empty user name check

-- Mention check
if string.find(text, "nickname") or string.find(text, "nick2") or string.find(text,"nick_2")  then
local enabled = "1"
if string.find(enabled, "1") then 
local texttosend = "You got mentioned by  " .. from_username .." Chat_name:  " .. chat_name .. " Chat_id:  " .. chat_id
do fwd_msg(receiverid, msg.id, ok_cb, false) end
do send_msg(receiverid, texttosend, ok_cb, false)
return 
end
end

else
return
end 
end
-- End of Mention check


return {
 description = "Mention Notifier",
 usage = "If someone uses one of added keywords, you get a private message from your bot",
 patterns = {
 "^(.+)$"
 }, 
 run = run 
}