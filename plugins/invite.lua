-- Invite other user to the chat group.
-- Use !invite name User_name or !invite id id_number
-- The User_name is the print_name (there are no spaces but _)

do

local function run(msg, matches)
  -- User submitted a user name
  if matches[1] == "name" then
    user_ = matches[2]
    user_ = string.gsub(user_," ","_")  
  -- User submitted an id
  elseif matches[1] == "id" then
    user_ = matches[2]
    user_ = 'user#id'..user_
  end

  -- The message must come from a chat group
  if msg.to.type == 'chat' then
    chat_id_ = 'chat#id'..msg.to.id
  else 
    return 'This isnt a chat group!'
  end

  print ("Trying to add: "..user_.." to "..chat_id_)
  local success = chat_add_user (chat_id_, user_, ok_cb, false)
  if not success then
    user_ = nil
    chat_id_ = nil
    return "An error happened"
  else
    local added = "Added user: "..user_.." to "..chat_id_
    user_ = nil
    chat_id_ = nil
    return added
  end
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
