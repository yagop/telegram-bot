-- Kick an user from the chat group.
-- Use !kick name User_name or !kick id id_number
-- The User_name is the print_name (there are no spaces but _)

--~ TODO:
--~ - !kick all
    --~ Get a list of users and kick them all (Useful for delete groups)
--~ - !kick new // !protect
    --~ Kick each new user who entered in the group
--~ - !ban user#id
    --~ Blacklist an user to enter a group

do

function ban(usr,chat)
  print ("Trying to kick: "..usr.." to "..chat)
  local success = chat_del_user (chat, usr, ok_cb, false)
  if not success then
    return "An error happened"
  else
    local kicked = "Kicked user: "..usr.." from "..chat
    return kicked
  end
end

function run(msg, matches)
    chat_ = 'chat#id'..msg.to.id
  -- The message must come from a chat group OR
  if msg.to.type ~= 'chat' then
    return 'This isn\'t a chat group!'
  end

  -- User submitted a user name
  if matches[1] == "name" then
    user_ = matches[2]
    user_ = string.gsub(user_," ","_")
    ban(user_,chat_)
  -- User submitted an id
  elseif  matches[1] == "id" then
    for i=2,#matches do
      user_ = 'user#id'..matches[i]
      ban(user_,chat_)
    end
  end
  user_ = nil
  chat_ = nil
end

return {
  description = "Ban an user from the chat group. Credits: @Rutrus",
  usage = {
    "!kick name [user_name]", 
    "!kick id [user_id]+" },
  patterns = {
    "^!kick (name) (.*)",
    "^!kick (id) (%d+)"
  }, 
  run = run,
  privileged = true
}
end
