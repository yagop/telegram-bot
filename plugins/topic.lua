
local function run(msg, matches)
  local text = matches[1]
  local chat = 'chat#id'..msg.to.id
  
  if msg.to.type == 'chat' then
    print('rename chat '..chat..' to '..text)
    rename_chat(chat, text, ok_cb, false)
  else
    return 'This isn\'t a chat group'
  end  
end

return {
  description = "set channel topic",
  usage = "!topic [whatever]: set channel topic",
  patterns = {
    "^!topic +(.+)$"
  }, 
  run = run 
}
