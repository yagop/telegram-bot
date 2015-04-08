do

local _file_votes = './data/votes.lua'

function read_file_votes ()
  local f = io.open(_file_votes, "r+")
  if f == nil then
    print ('Created voting file '.._file_votes)
    serialize_to_file({}, _file_votes)
  else
    print ('Values loaded: '.._file_votes)
    f:close()
  end
  return loadfile (_file_votes)()
end

function clear_votes (chat)
  local _votes = read_file_votes ()
  _votes [chat] = {}
  serialize_to_file(_votes, _file_votes)
end

function votes_result (chat)
  local _votes = read_file_votes ()
  local results = {}
  local result_string = ""
  if _votes [chat] == nil then
    _votes[chat] = {}
  end
  for user,vote in pairs (_votes[chat]) do
    if (results [vote] == nil) then
      results [vote] = user
    else
      results [vote] = results [vote] .. ", " .. user
    end
  end
  for vote,users in pairs (results) do
    result_string = result_string .. vote .. " : " .. users .. "\n"
  end
  return result_string
end


function save_vote(chat, user, vote)
  local _votes = read_file_votes ()
  if _votes[chat] == nil then
    _votes[chat] = {}
  end
  _votes[chat][user] = vote

  serialize_to_file(_votes, _file_votes)
  
end

function run(msg, matches)
  if (matches[1] == "ing") then
    if (matches [2] == "reset") then
      clear_votes (tostring(msg.to.id))
      return "Voting statistics reset.."
    elseif (matches [2] == "stats") then
      local votes_result = votes_result (tostring(msg.to.id))
      if (votes_result == "") then
        votes_result = "[No votes registered]\n"
      end
      return "Voting statistics :\n" .. votes_result
    end
  else
    save_vote(tostring(msg.to.id), msg.from.print_name, tostring(tonumber(matches[2])))
    return "Vote registered : " .. msg.from.print_name .. " " .. tostring(tonumber(matches [2]))
  end
end

return {
  description = "Plugin for voting in groups.", 
  usage = {
    "!voting reset: Reset all the votes.",
    "!vote [number]: Cast the vote.",
    "!voting stats: Shows the statistics of voting."
  },
  patterns = {
    "^!vot(ing) (reset)",
    "^!vot(ing) (stats)",
    "^!vot(e) ([0-9]+)$"
  }, 
  run = run 
}

end