do
-- Trivia plugin developed by Guy Spronck 

-- Returns the chat hash for storing information
local function get_hash(msg)
  local hash = nil
  if msg.to.type == 'chat' then
    hash = 'chat:'..msg.to.id..':trivia'
  end
  if msg.to.type == 'user' then
    hash = 'user:'..msg.from.id..':trivia'
  end
  return hash
end

-- Sets the question variables
local function set_question(msg, question, answer)
  local hash =get_hash(msg)
  if hash then
    redis:hset(hash, "question", question)
    redis:hset(hash, "answer", answer)
    redis:hset(hash, "time", os.time())
  end
end

-- Returns the current question
local function get_question( msg )
  local hash = get_hash(msg)
  if hash then
    local question = redis:hget(hash, 'question')
    if question ~= "NA" then
      return question
    end
  end
  return nil
end

-- Returns the answer of the last question
local function get_answer(msg)
  local hash = get_hash(msg)
  if hash then
    return redis:hget(hash, 'answer')
  else
    return nil
  end
end

-- Returns the time of the last question
local function get_time(msg)
  local hash = get_hash(msg)
  if hash then
    return redis:hget(hash, 'time')
  else
    return nil
  end
end

-- This function generates a new question if available
local function get_newquestion(msg)
  local timediff = 601
  if(get_time(msg)) then
    timediff = os.time() - get_time(msg)
  end
  if(timediff > 600 or get_question(msg) == nil)then
    -- Let's show the answer if no-body guessed it right.
    if(get_question(msg)) then
      send_large_msg(get_receiver(msg), "The question '" .. get_question(msg) .."' has not been answered. \nThe answer was '" .. get_answer(msg) .."'")
    end

    local url = "http://jservice.io/api/random/"
    local b,c = http.request(url)
    local query = json:decode(b)

    if query then
      local stringQuestion = ""
      if(query[1].category)then
        stringQuestion = "Category: " .. query[1].category.title .. "\n"
      end
      if query[1].question then
        stringQuestion = stringQuestion .. "Question: " .. query[1].question
        set_question(msg, query[1].question, query[1].answer:lower())
        return stringQuestion
      end
    end
    return 'Something went wrong, please try again.'
  else
    return 'Please wait ' .. 600 - timediff .. ' seconds before requesting a new question. \nUse !triviaquestion to see the current question.'
  end
end

-- This function generates a new question when forced
local function force_newquestion(msg)
    -- Let's show the answer if no-body guessed it right.
    if(get_question(msg)) then
      send_large_msg(get_receiver(msg), "The question '" .. get_question(msg) .."' has not been answered. \nThe answer was '" .. get_answer(msg) .."'")
    end

    local url = "http://jservice.io/api/random/"
    local b,c = http.request(url)
    local query = json:decode(b)

    if query then
      local stringQuestion = ""
      if(query[1].category)then
        stringQuestion = "Category: " .. query[1].category.title .. "\n"
      end
      if query[1].question then
        stringQuestion = stringQuestion .. "Question: " .. query[1].question
        set_question(msg, query[1].question, query[1].answer:lower())
        return stringQuestion
      end
    end
    return 'Something went wrong, please try again.'
end

-- This function adds a point to the player
local function give_point(msg)
  local hash = get_hash(msg)
  if hash then
    local score = tonumber(redis:hget(hash, msg.from.id) or 0)
    redis:hset(hash, msg.from.id, score+1)
  end
end

-- This function checks for a correct answer
local function check_answer(msg, answer)
  if(get_answer(msg)) then -- Safety for first time use
    if(get_answer(msg) == "NA")then
      -- Question has not been set, give a new one
      --get_newquestion(msg)
      return "No question set, please use !trivia first."
    elseif (get_answer(msg) == answer:lower()) then -- Question is set, lets check the answer 
      set_question(msg, "NA", "NA") -- Correct, clear the answer
      give_point(msg) -- gives out point to player for correct answer
      return msg.from.print_name .. " has answered correctly! \nUse !trivia to get a new question."
    else
      return "Sorry " .. msg.from.print_name .. ", but '" .. answer .. "' is not the correct answer!"
    end
  else
    return "No question set, please use !trivia first."
  end
end

local function user_print_name(user)
  if user.print_name then
    return user.print_name
  end

  local text = ''
  if user.first_name then
    text = user.last_name..' '
  end
  if user.lastname then
    text = text..user.last_name
  end

  return text
end


local function get_user_score(msg, user_id, chat_id)
  local user_info = {}
  local uhash = 'user:'..user_id
  local user = redis:hgetall(uhash)
  local hash = 'chat:'..msg.to.id..':trivia'
  user_info.score = tonumber(redis:hget(hash, user_id) or 0)
  user_info.name = user_print_name(user)..' ('..user_id..')'
  return user_info
end

-- Function to print score
local function trivia_scores(msg)
  if msg.to.type == 'chat' then
    -- Users on chat
    local hash = 'chat:'..msg.to.id..':users'
    local users = redis:smembers(hash)
    local users_info = {}

    -- Get user info
    for i = 1, #users do
      local user_id = users[i]
      local user_info = get_user_score(msg, user_id, msg.to.id)
      table.insert(users_info, user_info)
    end

    table.sort(users_info, function(a, b) 
        if a.score and b.score then
          return a.score > b.score
        end
      end)

    local text = ''
    for k,user in pairs(users_info) do
      text = text..user.name..' => '..user.score..'\n'
    end

    return text
  else
    return "This function is only available in group chats."
  end
end

local function run(msg, matches)
  if(matches[1] == "!triviascore" or matches[1] == "!triviascores") then
    -- Output all scores
    return trivia_scores(msg)
  elseif(matches[1] == "!triviaquestion")then
    return "Question: " .. get_question(msg)
  elseif(matches[1] == "!triviaskip") then
    if is_sudo(msg) then
      return force_newquestion(msg) 
    end
  elseif(matches[1] ~= "!trivia") then
    return check_answer(msg, matches[1])
  end

  return get_newquestion(msg)
end

return {
  description = "Trivia plugin for Telegram",
  usage = {
    "!trivia to obtain a new question.",
    "!trivia [answer] to answer the question.",
    "!triviaquestion to show the current question.",
    "!triviascore to get a scoretable of all players.",
    "!triviaskip to skip a question (requires sudo)"
  },
  patterns = {"^!trivia (.*)$",
              "^!trivia$",
              "^!triviaquestion$",
              "^!triviascore$",
              "^!triviascores$",
              "^!triviaskip$"},
  run = run
}

end
