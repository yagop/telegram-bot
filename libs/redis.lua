local Redis = require 'redis'
local FakeRedis = require 'fakeredis'

local params = {
  host = os.getenv('REDIS_HOST') or '127.0.0.1',
  port = tonumber(os.getenv('REDIS_PORT') or 6379)
}

local database = os.getenv('REDIS_DB')
local password = os.getenv('REDIS_PASSWORD')

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
local ok = pcall(function()
  redis = Redis.connect(params)
end)

if not ok then

  local fake_func = function()
    print('\27[31mCan\'t connect with Redis, install/configure it!\27[39m')
  end
  fake_func()
  fake = FakeRedis.new()

  print('\27[31mRedis addr: '..params.host..'\27[39m')
  print('\27[31mRedis port: '..params.port..'\27[39m')

  redis = setmetatable({fakeredis=true}, {
  __index = function(a, b)
    if b ~= 'data' and fake[b] then
      fake_func(b)
    end
    return fake[b] or fake_func
  end })

else
  if password then
    redis:auth(password)
  end
  if database then
    redis:select(database)
  end
end


return redis
