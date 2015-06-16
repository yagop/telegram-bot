--[[ 
This autoanswer script will let your bot answer automatically depending on some keywords. 

For example, like how set on this script, you can let the bot greet everyone if someone on a random part of the message says "Hi all" (there is no case sensivity.) 

Update 2015_06_16: added a local enabled variable, in order to set it to 0, without having to delete the keywords, useful for temporary disable of that match.


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


-- Keyword autoanswer 
if string.find(text, "Hi all") then
local enabled = "1"
if string.find(enabled, "1") then 
local botanswers = {"hey ".. from_username .. " !","hi ".. from_username .. " !"}
return botanswers[math.random(#botanswers)]
end


else
return
end 
end

return {
 description = "Autoanswer",
 usage = "You write, i reply",
 patterns = {
 "^(.+)$"
 }, 
 run = run 
}