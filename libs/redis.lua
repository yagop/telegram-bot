local Redis = require 'redis'

local params = {
  host = '127.0.0.1',
  port = 6379,
}

local redis = nil

-- Won't launch an error if fails
pcall(function()
  redis = Redis.connect(params)
end)

return redis