-- Saves the number of messages from a user
-- Can check the number of messages with !stats 

do

local socket = require('socket') 
local _file_stats = './data/stats.lua'
local _stats

function update_user_stats(msg)
  -- Save user to stats table
  local from_id = tostring(msg.from.id)
  local to_id = tostring(msg.to.id)
  local user_name = get_name(msg)
  print ('New message from '..user_name..'['..from_id..']'..' to '..to_id)
  -- If last name is nil dont save last_name.
  local user_last_name = msg.from.last_name
  local user_print_name = msg.from.print_name
  if _stats[to_id] == nil then
    print ('New stats key to_id: '..to_id)
    _stats[to_id] = {}
  end
  if _stats[to_id][from_id] == nil then
    print ('New stats key from_id: '..to_id)
    _stats[to_id][from_id] = {
      user_id = from_id,
      name = user_name,
      last_name = user_last_name,
      print_name = user_print_name,
      msg_num = 1
    }
  else
    print ('Updated '..to_id..' '..from_id)
    local actual_num = _stats[to_id][from_id].msg_num
    _stats[to_id][from_id].msg_num = actual_num + 1
    _stats[to_id][from_id].user_id = from_id
    _stats[to_id][from_id].last_name = user_last_name
  end
end

function read_file_stats( )
  local f = io.open(_file_stats, "r+")
  -- If file doesn't exists
  if f == nil then
    -- Create a new empty table
    print ('Created user stats file '.._file_stats)
    serialize_to_file({}, _file_stats)
  else
    print ('Stats loaded: '.._file_stats)
    f:close() 
  end
  return loadfile (_file_stats)()
end


local function save_stats()
  -- Save stats to file
  serialize_to_file(_stats, _file_stats)
end

local function get_stats_status( msg )
  -- vardump(stats)
  local text = ""
  local to_id = tostring(msg.to.id)
  local rank = {}

  for id, user in pairs(_stats[to_id]) do
    table.insert(rank, user)
  end

  table.sort(rank, function(a, b) 
      if a.msg_num and b.msg_num then
        return a.msg_num > b.msg_num
      end
    end
  )

  for id, user in pairs(rank) do
    -- Previous versions didn't save that
    user_id = user.user_id or ''
    print(">> ", id, user.name)
    if user.last_name == nil then
      text = text..user.name.." ["..user_id.."]: "..user.msg_num.."\n"
    else
      text = text..user.name.." "..user.last_name.." ["..user_id.."]: "..user.msg_num.."\n"
    end
  end
  print("usuarios: "..text)
  return text
end

local function run(msg, matches)
  if matches[1] == "stats" then
    if msg.to.type == 'chat' or is_sudo(msg) then
      return get_stats_status(msg)
    else
      return 'Stats works only chats'
    end
  else 
    update_user_stats(msg)
  end
end

_stats = read_file_stats()

return {
  description = "Plugin to update user stats.", 
  usage = "!stats: Returns a list of Username [telegram_id]: msg_num",
  patterns = {
    "^!(stats)",
    ".*"
    }, 
  run = run,
  cron = save_stats
}

end
