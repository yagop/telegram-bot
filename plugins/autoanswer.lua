--[[ 
This auto answer script will let your bot answer on the same chat/group automatically depending on some keywords. 

For example, like how set on this script, you can let the bot greet someone if on a random part of his message there is the text "hi all" 

(There is no case sensitivity. In the case you want to disable case insensitivity, just comment with "--" the line "local text = string.lower(msg.text)") 

Update 2015_06_16: 
- added a local enabled variable, in order to set it to 0, without having to delete the keywords, useful for temporary disable of that match.
- added empty nickname checking
- bug fixes

Update 2015_10_30:
Syntax
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
	
	-- Use OR and AND functions to achieve the desidered phrase
	-- change the enabled var from 1 to 0 to disable a specific check
	-- Keyword autoanswer 
	if string.find(text, "Hi") and string.find(text, "YagopBot") or string.find(text, "Yagop Bot") then
		local enabled = "1"
		if string.find(enabled, "1") then 
			local botanswers = {from_username .." Hello","Beep Bop... "}
		return botanswers[math.random(#botanswers)]
		end
	end
end

return {
 description = "AutoAnswer",
 usage = "You write, i reply",
 patterns = {
 "^(.+)$"
 }, 
 run = run 
}