local Redis = require 'redis'

local params = {
  host = '127.0.0.1',
  port = 6379,
}

-- Overwrite HGETALL
Redis.commands.hgetall = Redis.command('hgetall', {
  response = function(reply, command, ...)
    local new_reply = { }
    for i = 1, #reply, 2 do new_reply[reply[i]] = reply[i + 1] end
    return new_reply
  end
})

local redis = nil

-- Won't launch an error if fails
pcall(function()
  redis = Redis.connect(params)
end)

return redis