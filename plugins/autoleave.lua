--[[
Kicking ourself (bot) from unmanaged groups.

When someone invited this bot to a group, the bot then will chek if the group is in its moderations (moderation.json). If not, the bot will exit immediately by kicking itself out of that group.

No switch available. You need to turn it on or off using !plugins command.

Testing needed.
--]]

local function run (msg)
  local user_id = msg.from.id
  local chat_id = msg.to.id
  local data = load_data(_config.moderation.data)
  if msg.service and msg.action.type == "chat_add_user" then
    if data[tostring(chat_id)] then
      print 'This is our group.'
    else
      print "This is not our group. Leaving..."
      chat_del_user('chat#id'..chat_id, 'user#id'..our_id, cb_ok, false)
    end
  end
end

return {
  description = "Kicking ourself (bot) from unmanaged groups.",
  patterns = {
    "^!!tgservice (.+)$"
  },
  run = run
}
