do

  local function get_base_redis(id, option, extra)
    local ex = ''

    if option ~= nil then
      ex = ex .. ':' .. option
      if extra ~= nil then
        ex = ex .. ':' .. extra
      end
    end
    return 'rss:' .. id .. ex
  end

  local function prot_url(url)
    local url, h = url:gsub('http://', '')
    local url, hs = url:gsub('https://', '')
    local protocol = 'http'

    if hs == 1 then
      protocol = 'https'
    end
    return url, protocol
  end

  local function get_rss(url, prot)
    local res, code = nil, 0

    if prot == 'http' then
      res, code = http.request(url)
    elseif prot == 'https' then
      res, code = https.request(url)
    end
    if code ~= 200 then
      return nil, 'Error while doing the petition to ' .. url
    end

    local parsed = feedparser.parse(res)

    if parsed == nil then
      return nil, 'Error decoding the RSS.\nAre you sure that ' .. url .. ' is an RSS?'
    end
    return parsed, nil
  end

  local function get_new_entries(last, nentries)
    local entries = {}

    for k,v in pairs(nentries) do
      if v.id == last then
        return entries
      else
        table.insert(entries, v)
      end
    end
    return entries
  end

  local function print_subs(msg, id)
    local subscriber = msg.to.title

    if id:match('user') then
      subscriber = 'You'
    end

    local uhash = get_base_redis(id)
    local subs = redis:smembers(uhash)
    local text = subscriber .. ' are subscribed to:\n---------\n'

    for k,v in pairs(subs) do
      text = text .. k .. ') ' .. v .. '\n'
    end

    reply_msg(msg.id, text, ok_cb, true)
  end

  local function subscribe(msg, id, url)
    local baseurl, protocol = prot_url(url)
    local prothash = get_base_redis(baseurl, 'protocol')
    local lasthash = get_base_redis(baseurl, 'last_entry')
    local lhash = get_base_redis(baseurl, 'subs')
    local uhash = get_base_redis(id)

    if redis:sismember(uhash, baseurl) then
      reply_msg(msg.id, 'You are already subscribed to ' .. url, ok_cb, true)
    end

    local parsed, err = get_rss(url, protocol)

    if err ~= nil then
      return err
    end

    local last_entry = ''

    if #parsed.entries > 0 then
      last_entry = parsed.entries[1].id
    end

    local name = parsed.feed.title

    redis:set(prothash, protocol)
    redis:set(lasthash, last_entry)
    redis:sadd(lhash, id)
    redis:sadd(uhash, baseurl)

    reply_msg(msg.id, 'You had been subscribed to ' .. name, ok_cb, true)
  end

  local function unsubscribe(msg, id, n)
    if #n > 3 then
      reply_msg(msg.id, "I don't think that you have that many subscriptions.", ok_cb, true)
    end

    n = tonumber(n)
    local uhash = get_base_redis(id)
    local subs = redis:smembers(uhash)

    if n < 1 or n > #subs then
      reply_msg(msg.id, 'Subscription id out of range!', ok_cb, true)
    end

    local sub = subs[n]
    local lhash = get_base_redis(sub, 'subs')

    redis:srem(uhash, sub)
    redis:srem(lhash, id)

    local left = redis:smembers(lhash)

    if #left < 1 then -- no one subscribed, remove it
      local prothash = get_base_redis(sub, 'protocol')
      local lasthash = get_base_redis(sub, 'last_entry')
      redis:del(prothash)
      redis:del(lasthash)
    end

    reply_msg(msg.id, 'You had been unsubscribed from ' .. sub, ok_cb, true)
  end

  local function cron()
    -- sync every 15 mins?
    local keys = redis:keys(get_base_redis('*', 'subs'))

    for k,v in pairs(keys) do
      local base = v:match('rss:(.+):subs')  -- Get the URL base
      local prot = redis:get(get_base_redis(base, 'protocol'))
      local last = redis:get(get_base_redis(base, 'last_entry'))
      local url = prot .. '://' .. base
      local parsed, err = get_rss(url, prot)

      if err ~= nil then
        return
      end

      local newentr = get_new_entries(last, parsed.entries)
      local subscribers = {}
      local text = ''  -- Send only one message with all updates

      for k2, v2 in pairs(newentr) do
        local title = v2.title or 'No title'
        local link = v2.link or v2.id or 'No Link'
        text = text .. k2 .. '. ' .. title .. '\n' .. link .. '\n'
      end
      if text ~= '' then
        local newlast = newentr[1].id
        redis:set(get_base_redis(base, 'last_entry'), newlast)
        for k2, receiver in pairs(redis:smembers(v)) do
          send_msg(receiver, text, ok_cb, false)
        end
      end
    end
  end

  --------------------------------------------------------------------------------

  local function run(msg, matches)

    local uid = msg.from.peer_id

    -- comment this line if you want this plugin works for all members.
    if not is_owner(msg, msg.to.peer_id , uid) then return nil end

    local id = get_receiver(msg)

    if matches[1] == '!rss'then
      print_subs(msg, id)
    end
    if matches[1] == 'sync' then
      if not is_sudo(uid) then
        reply_msg(msg.id, 'Only sudo users can sync the RSS.', ok_cb, true)
      else
        cron()
      end
    end
    if matches[1] == 'subscribe' or matches[1] == 'sub' then
      subscribe(msg, id, matches[2])
    end
    if matches[1] == 'unsubscribe' or matches[1] == 'uns' then
      unsubscribe(msg, id, matches[2])
    end
  end

  --------------------------------------------------------------------------------


  return {
    description = 'Manage User/Chat RSS subscriptions. If you are in a chat group, the RSS subscriptions will be of that chat. If you are in an one-to-one talk with the bot, the RSS subscriptions will be yours.',
    usage = {
      admin = {
        '<code>!rss</code>',
        'Get your rss (or chat rss) subscriptions',
        '',
        '<code>!rss subscribe [url]</code>',
        'Subscribe to that url',
        '',
        '<code>!rss unsubscribe [id]</code>',
        'Unsubscribe of that id',
        '',
        '<code>!rss sync</code>',
        'Download now the updates and send it. Only sudo users can use this option.'
      },
    },
    patterns = {
      '^!rss$',
      '^!rss (subscribe) (https?://[%w-_%.%?%.:/%+=&]+)$',
      '^!rss (sub) (https?://[%w-_%.%?%.:/%+=&]+)$',
      '^!rss (unsubscribe) (%d+)$',
      '^!rss (uns) (%d+)$',
      '^!rss (sync)$'
    },
    run = run,
    cron = cron
  }

end
