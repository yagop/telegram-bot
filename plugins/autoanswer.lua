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