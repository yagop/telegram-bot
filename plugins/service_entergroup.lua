local add_user_cfg = load_from_file('data/add_user_cfg.lua')

local function template_add_user(base, to_username, from_username, chat_name, chat_id)
   base = base or ''
   to_username = (to_username or '')
   from_username = (from_username or '')
   chat_name = chat_name or ''
   chat_id = "chat#id" .. (chat_id or '')
   base = string.gsub(base, "{to_username}", to_username)
   base = string.gsub(base, "{from_username}", from_username)
   base = string.gsub(base, "{chat_name}", chat_name)
   base = string.gsub(base, "{chat_id}", chat_id)
   return base
end

function chat_new_user_link(msg)
   -- if a user entered a group chat
   local pattern = add_user_cfg.initial_chat_msg_link
   -- change message if self invite via link
   if msg.from.id == our_id then
     pattern = add_user_cfg.invited_chat_msg_link
   end
   
   local to_username = msg.from.username
   local chat_name = msg.to.print_name
   local chat_id = msg.to.id
   pattern = template_add_user(pattern, to_username, from_username, chat_name, chat_id)
   if pattern ~= '' then
      local receiver = get_receiver(msg)
      send_msg(receiver, pattern, ok_cb, false)
   end
end

function chat_new_user(msg)

   -- if a user were invited into a grouo
   local pattern = add_user_cfg.initial_chat_msg
   -- change message if bot's was invited
   if msg.action.user.id == our_id then
     pattern = add_user_cfg.invited_chat_msg
   end
  
   local to_username = msg.action.user.print_name
   -- change to username if exists
   if msg.action.user.username then
     to_username = '@'..msg.action.user.username
   end

   local from_username = msg.from.print_name
   -- change to username if exists
   if msg.from.username then
     from_username = '@'..msg.from.username
   end

   local chat_name = msg.to.print_name
   local chat_id = msg.to.id
   pattern = template_add_user(pattern, to_username, from_username, chat_name, chat_id)
   if pattern ~= '' then
      local receiver = get_receiver(msg)
      send_msg(receiver, pattern, ok_cb, false)
   end
end


local function run(msg, matches)
   if not msg.service then
      return "Are you trying to troll me?"
   end
   if matches[1] == "chat_add_user" then
      chat_new_user(msg)
   elseif matches[1] == "chat_add_user_link" then
      chat_new_user_link(msg)
   end
end

return {
   description = "Service plugin that sends a custom message when an user enters a chat.",
   usage = "",
   patterns = {
      "^!!tgservice (chat_add_user)$",
      "^!!tgservice (chat_add_user_link)$"
   },
   run = run
}
