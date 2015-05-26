local add_user_cfg = load_from_file('data/add_user_cfg.lua')

local function template_add_user(base, to_username, from_username, chat_name, chat_id)
   if to_username == "@" then
      to_username = ''
   end
   if from_username == "@" then
      from_username = ''
   end
   base = string.gsub(base, "{to_username}", to_username)
   base = string.gsub(base, "{from_username}", from_username)
   base = string.gsub(base, "{chat_name}", chat_name)
   base = string.gsub(base, "{chat_id}", chat_id)
   return base
end

function chat_new_user_link(msg)
   local pattern = add_user_cfg.initial_chat_msg or ''
   local to_username = '@' .. msg.from.username
   local from_username = '[link](@' .. msg.action.link_issuer.username .. ')'
   local chat_name = msg.to.print_name or ''
   local chat_id = 'chat#id' .. msg.to.id
   pattern = template_add_user(pattern, to_username, from_username, chat_name, chat_id)
   if pattern ~= '' then
      local receiver = get_receiver(msg)
      send_msg(receiver, pattern, ok_cb, false)
   end
end

function chat_new_user(msg)
   local pattern = add_user_cfg.initial_chat_msg or ''
   local to_username = '@' .. msg.action.user.username
   local from_username = '@' .. msg.from.username
   local chat_name = msg.to.print_name or ''
   local chat_id = 'chat#id' .. msg.to.id
   pattern = template_add_user(pattern, to_username, from_username, chat_name, chat_id)
   if pattern ~= '' then
      local receiver = get_receiver(msg)
      send_msg(receiver, pattern, ok_cb, false)
   end
end


local function run(msg, matches)
   if not msg.realservice then
      return "Are you trying to troll me?"
   end
   if matches[1] == "chat_add_user" then
      chat_new_user(msg)
   elseif mathes[1] == "chat_add_user_link" then
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
