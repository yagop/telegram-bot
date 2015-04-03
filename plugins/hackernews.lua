do

function run(msg, matches)
  local result = 'Hacker News Top5:\n'
  local top_stories_json, code = https.request('https://hacker-news.firebaseio.com/v0/topstories.json')
  if code ~=200 then return nil  end
  local top_stories = json:decode(top_stories_json)
  for i = 1, 5 do
    local story_json, code = https.request('https://hacker-news.firebaseio.com/v0/item/'..top_stories[i]..'.json')
    if code ~=200 then return nil  end
    local story = json:decode(story_json)
    result = result .. i .. '. ' .. story.title .. ' - ' .. story.url .. '\n'
  end
  return result
end

return {
  description = "Show top 5 hacker news (ycombinator.com)",
  usage = "!hackernews",
  patterns = {"^!hackernews$"},
  run = run
}

end
