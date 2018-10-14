do

  local function run(msg, matches)
    local jstr, res = https.request('https://hacker-news.firebaseio.com/v0/topstories.json')

    if res ~= 200 then
      bot_sendMessage(get_receiver_api(msg), 'Connection error.', true, msg.id, 'html')
      return
    end

    local jdat = json:decode(jstr)
    local res_count = 8
    local header = '<b>Hacker News</b>\n\n'
    local hackernew = {}

    for i = 1, res_count do
      local res_url = 'https://hacker-news.firebaseio.com/v0/item/' .. jdat[i] .. '.json'
      local jstr, res = https.request(res_url)

      if res ~= 200 then
        send_message(msg, '<b>Connection error</b>', 'html')
        return
      end

      local res_jdat = json:decode(jstr)
      local title = res_jdat.title:gsub('%[.+%]', ''):gsub('%(.+%)', ''):gsub('&amp;', '&')

      if title:len() > 48 then
        title = title:sub(1, 45) .. '...'
      end

      local url = res_jdat.url

      if not url then
        send_message(msg, '<b>Connection error</b>', 'html')
        return
      end

      local title = unescape_html(title)

      hackernew[i] = '<b>' .. i .. '</b>. <a href="' .. url .. '">' .. title .. '</a>\n'
    end

    local hackernews = table.concat(hackernew)

    bot_sendMessage(get_receiver_api(msg), header .. hackernews, true, msg.id, 'html')
  end

  return {
    description = 'Returns top stories from Hacker News.',
    usage = {
      '<code>!hackernews</code>',
      '<code>!hn</code>',
      'Returns top stories from Hacker News.',
    },
    patterns = {
      '^!(hackernews)$',
      '^!(hn)$',
    },
    run = run
  }

end
