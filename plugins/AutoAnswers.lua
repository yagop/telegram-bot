--[[ 
This auto answer script will let your bot answer on the same chat/group automatically depending on some keywords. 

For example, like how set on this script, you can let the bot greet someone if on a random part of his message there is the text "hi all" 

(There is no case sensitivity. In the case you want to disable case insensitivity, just comment with "--" the line "local text = string.lower(msg.text)") 

Update 2015_06_16: 
- added a local enabled variable, in order to set it to 0, without having to delete the keywords, useful for temporary disable of that match.
- added empty nickname checking
- bug fixes


 ]]--

local function run(msg)
local text = string.lower(msg.text) -- disable this for case sensitivity
local origin = get_receiver(msg)
local chat_id = msg.to.id
local chat_name = msg.to.print_name


-- Empty user name check
if not msg.from.username then
from_username = "" 
else
from_username = ('@' .. msg.from.username)
end

-- End of empty user name check



-- Keyword auto answer 
-- Group one
if string.find(text, "hi all") then
local enabled = "1"
if string.find(enabled, "1") then 
local botanswers = {"hey ".. from_username .. " !","hi ".. from_username .. " !"}
return botanswers[math.random(#botanswers)]
end

-- Group two
elseif string.find(text, "hi everyone") or string.find(text, "forza roma") or string.find(text, "as roma") then
local enabled = "1"
if string.find(enabled, "1") then 
local botanswers = {"hey ".. from_username .. " !","hi ".. from_username .. " !"}
return botanswers[math.random(#botanswers)]
end

-- Group three

-- Group whatever you want







else
return
end 
end
-- end of Keyword auto answer


return {
 description = "Auto answer",
 usage = "If someone uses one of added keywords, your bot answers on the same chat/group",
 patterns = {
 "^(.+)$"
 }, 
 run = run 
}