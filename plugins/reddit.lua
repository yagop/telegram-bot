do

  local function run(msg, matches)
    local thread_limit = 5
    local is_nsfw = false

    if not is_chat_msg(msg) then
      thread_limit = 8
    end

    if matches[1] == 'nsfw' then
      is_nsfw = true
    end

    if matches[2] then
      if matches[2]:match('^r/') then
        url = 'https://www.reddit.com/' .. URL.escape(matches[2]) .. '/.json?limit=' .. thread_limit
      else
        url = 'https://www.reddit.com/search.json?q=' .. URL.escape(matches[2]) .. '&limit=' .. thread_limit
      end
    elseif msg.text == '!reddit' then
      url = 'https://www.reddit.com/.json?limit=' .. thread_limit
    end

    -- Do the request
    local res, code = https.request(url)

    if code ~= 200 then
      send_message(msg, "<b>There doesn't seem to be anything</b>...", 'html')
    end

    local jdat = json:decode(res)
    local jdata_child = jdat.data.children

    if #jdata_child == 0 then
      return nil
    end

    local threadit = {}
    local long_url = ''

    for k=1, #jdata_child do
      local redd = jdata_child[k].data

      if not redd.is_self then
        local link = URL.parse(redd.url)
        long_url = '\nLink: <a href="' .. redd.url .. '">' .. link.scheme .. '://' .. link.host .. '</a>'
      end

      local title = unescape_html(redd.title)

      if redd.over_18 and not is_nsfw then
        threadit[k] = ''
      elseif redd.over_18 and is_nsfw then
        threadit[k] = '<b>' .. k .. '. NSFW</b> ' .. '<a href="redd.it/' .. redd.id .. '">' .. title .. '</a>' .. long_url
      else
        threadit[k] = '<b>' .. k .. '. </b>' .. '<a href="redd.it/' .. redd.id .. '">' .. title .. '</a>' .. long_url
      end
    end

    local threadit = table.concat(threadit, '\n')
    local subreddit = '<b>' .. (matches[2] or 'redd.it') .. '</b>\n\n'
    local subreddit = subreddit .. threadit

    if not threadit:match('%w+') then
      send_message(msg, '<b>You must be 18+ to view this community.</b>', 'html')
    else
      bot_sendMessage(get_receiver_api(msg), subreddit, true, msg.id, 'html')
    end
  end

--------------------------------------------------------------------------------

  return {
    description = 'Returns the five (if group) or eight (if private message) top posts for the given subreddit or query, or from the frontpage.',
    usage = {
      '<code>!reddit</code>',
      'Reddit frontpage.',
      '',
      '<code>!reddit r/[query]</code>',
      '<code>!r r/[query]</code>',
      'Subreddit',
      '<b>Example</b>: <code>!r r/linux</code>',
      '',
      '<code>!redditnsfw [query]</code>',
      '<code>!rnsfw [query]</code>',
      'Subreddit (include NSFW).',
      '<b>Example</b>: <code>!rnsfw r/juicyasians</code>',
      '',
      '<code>!reddit [query]</code>',
      '<code>!r [query]</code>',
      'Search subreddit.',
      '<b>Example</b>: <code>!r telegram bot</code>',
      '',
      '<code>!redditnsfw [query]</code>',
      '<code>!rnsfw [query]</code>',
      'Search subreddit (include NSFW).',
      '<b>Example</b>: <code>!rnsfw maria ozawa</code>',
    },
    patterns = {
      '^!reddit$',
      '^!(r) (.*)$',
      '^!(reddit) (.*)$',
      '^!r(nsfw) (.*)$',
      '^!reddit(nsfw) (.*)$'
    },
    run = run
  }

end
