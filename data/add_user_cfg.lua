do 
_ = {

  -- when a user were invited by other member
  initial_chat_msg = "Hi {to_username} welcome to chat {chat_name}!\nYou has been added by {from_username}",
  -- {to_username} {from_username} {chat_name} {chat_id}

  -- when a user joined via invite link
  initial_chat_msg_link = "Hi {to_username} welcome to chat {chat_name}!\nYou has joined this group via invite link",

  -- when bot was invited into a group chat
  invited_chat_msg = "Thank you {from_username} for inviting me into your group. You can type !help to start using me.",

  -- when bot joined via invite link
  invited_chat_msg_link = "Thank you to myself because joined chat {chat_name} via invite link :P"
}

return _
end
