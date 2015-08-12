do

local function parsed_url(link)
  local parsed_link = URL.parse(link)
  local parsed_path = URL.parse_path(parsed_link.path)
  return parsed_path[2]
end

function run(msg, matches)
  local hash = parsed_url(matches[1])   
  join = import_chat_link(hash,ok_cb,false)
end


return {
  description = "Invite me into a group chat", 
  usage = "!inviteme [invite link]",
  patterns = {
    "^!inviteme (.*)$"
  }, 
  run = run
}

end
