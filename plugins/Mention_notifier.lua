--[[ 
This autoanswer script will let your bot write a message to your private chat, if some keyword listed is used, fox example when someone uses you nickname, but doesn't add @ before, so you won't get mentioned. 

Update 2015_06_16: 
- added a local enabled variable, in order to set it to 0, without having to delete the keywords, useful for temporary disable of that match.
- added empty nickname checkings


For questions: 
Sempiternum, sempiternvm@gmail.com

 ]]--

local function run(msg)
local text = string.lower(msg.text)
local origin = get_receiver(msg)
local chat_id = msg.to.id
local chat_name = msg.to.print_name


-- Empty username check
if not msg.from.username then
from_username = msg.from.print_name
else
local from_username = ('@' .. msg.from.username)
end
-- End of empty username check

-- notifier --
elseif string.find(text, "YOUR_NICKNAME") or string.find(text, "YOUR_NICKNAME2") or string.find(text,"NICKNAME") then
local enabled = "1"
if string.find(enabled, "1") then 
receiverid = 'user#id00000000'
texttosend = "you got mentioned by  " .. from_username .." Chat_name:  " .. chat_name .. " Chat_id:  " .. chat_id
do fwd_msg(receiverid, msg.id, ok_cb, false) end
do send_msg(receiverid, texttosend, ok_cb, false)
return 
end
end
-- end of notifier --