local function returnids(cb_extra, success, result)
   local receiver = cb_extra.receiver
   local chat_id = result.id
   local chatname = result.print_name
   for k,v in pairs(result.members) do
      send_large_msg(v.print_name, text)
   end
   send_large_msg(receiver, 'Message broadcasted succesfully')
end

local function run(msg, matches)
   local receiver = get_receiver(msg)
   if not is_chat_msg(msg) then
      return 'Broadcast only works on group'
   end
   if matches[1] then
      text = 'Message for all member of ' .. string.gsub(msg.to.print_name, '_', ' ') .. ' :'
      text = text .. '\n\n' .. matches[1]
      local chat = get_receiver(msg)
      chat_info(chat, returnids, {receiver=receiver})
   end
end

return {
   description = "Broadcast message to all group participant.",
   usage = {
      "!broadcast <message to broadcast>",
   },
   patterns = {
      "^!broadcast +(.+)$"
   },
   run = run,
   moderated = true
}
