-- Invite other user to the chat group.
-- Use !invite name User_name or !invite id id_number
-- The User_name is the print_name (there are no spaces but _)

do

local function run(msg, matches)
  -- User submitted a user name
  if matches[1] == "name" then
    local user = matches[2]
    user = string.gsub(user," ","_")
  end
  
  -- User submitted an id
  if matches[1] == "id" then
    local user = matches[2]
    user = 'user#id'..user
  end

  -- The message must come from a chat group
  if msg.to.type == 'chat' then
    local chat = 'chat#id'..msg.to.id
  else 
    return 'This isnt a chat group!'
  end

  print ("Trying to add: "..user.." to "..chat)
  local status = chat_add_user (chat, user, ok_cb, false)
  if not status then
    return "An error happened"
  end
  return "Added user: "..user.." to "..chat
end

return {
  description = "Invite other user to the chat group", 
  usage = {
    "!invite name [user_name]", 
    "!invite id [user_id]" },
  patterns = {
    "^!invite (name) (.*)$",
    "^!invite (id) (%d+)$"
  }, 
  run = run 
}

end