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
   local url, h = string.gsub(url, "http://", "")
   local url, hs = string.gsub(url, "https://", "")
   local protocol = "http"
   if hs == 1 then
      protocol = "https"
   end
   return url, protocol
end

local function get_rss(url, prot)
   local res, code = nil, 0
   if prot == "http" then
      res, code = http.request(url)
   elseif prot == "https" then
      res, code = https.request(url)
   end
   if code ~= 200 then
      return nil, "Error while doing the petition to " .. url
   end
   local parsed = feedparser.parse(res)
   if parsed == nil then
      return nil, "Error decoding the RSS.\nAre you sure that " .. url .. " it's a RSS?"
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

local function print_subs(id)
   local uhash = get_base_redis(id)
   local subs = redis:smembers(uhash)
   local text = id .. ' are subscribed to:\n---------\n'
   for k,v in pairs(subs) do
      text = text .. k .. ") " .. v .. '\n'
   end
   return text
end

local function subscribe(id, url)
   local baseurl, protocol = prot_url(url)

   local prothash = get_base_redis(baseurl, "protocol")
   local lasthash = get_base_redis(baseurl, "last_entry")
   local lhash = get_base_redis(baseurl, "subs")
   local uhash = get_base_redis(id)

   if redis:sismember(uhash, baseurl) then
      return "You are already subscribed to " .. url
   end

   local parsed, err = get_rss(url, protocol)
   if err ~= nil then
      return err
   end

   local last_entry = ""
   if #parsed.entries > 0 then
      last_entry = parsed.entries[1].id
   end

   local name = parsed.feed.title

   redis:set(prothash, protocol)
   redis:set(lasthash, last_entry)
   redis:sadd(lhash, id)
   redis:sadd(uhash, baseurl)

   return "You had been subscribed to " .. name
end

local function unsubscribe(id, n)
   if #n > 3 then
      return "I don't think that you have that many subscriptions."
   end
   n = tonumber(n)

   local uhash = get_base_redis(id)
   local subs = redis:smembers(uhash)
   if n < 1 or n > #subs then
      return "Subscription id out of range!"
   end
   local sub = subs[n]
   local lhash = get_base_redis(sub, "subs")

   redis:srem(uhash, sub)
   redis:srem(lhash, id)

   local left = redis:smembers(lhash)
   if #left < 1 then -- no one subscribed, remove it
      local prothash = get_base_redis(sub, "protocol")
      local lasthash = get_base_redis(sub, "last_entry")
      redis:del(prothash)
      redis:del(lasthash)
   end

   return "You had been unsubscribed from " .. sub
end

local function cron()
   -- sync every 15 mins?
   local keys = redis:keys(get_base_redis("*", "subs"))
   for k,v in pairs(keys) do
      local base = string.match(v, "rss:(.+):subs")  -- Get the URL base
      local prot = redis:get(get_base_redis(base, "protocol"))
      local last = redis:get(get_base_redis(base, "last_entry"))
      local url = prot .. "://" .. base
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
         text = text .. "[rss](" .. link .. ") - " .. title .. '\n'
      end
      if text ~= '' then
         local newlast = newentr[1].id
         redis:set(get_base_redis(base, "last_entry"), newlast)
         for k2, receiver in pairs(redis:smembers(v)) do
            send_msg(receiver, text, ok_cb, false)
         end
      end
   end
end

local function run(msg, matches)
   local id = "user#id" .. msg.from.id

   if is_chat_msg(msg) then
      id = "chat#id" .. msg.to.id
   end

   if matches[1] == "!rss"then
      return print_subs(id)
   end
   if matches[1] == "sync" then
      if not is_sudo(msg) then
         return "Only sudo users can sync the RSS."
      end
      cron()
   end
   if matches[1] == "subscribe" or matches[1] == "sub" then
      return subscribe(id, matches[2])
   end

   if matches[1] == "unsubscribe" or matches[1] == "uns" then
      return unsubscribe(id, matches[2])
   end
end


return {
   description = "Manage User/Chat RSS subscriptions. If you are in a chat group, the RSS subscriptions will be of that chat. If you are in an one-to-one talk with the bot, the RSS subscriptions will be yours.",
   usage = {
      "!rss: Get your rss (or chat rss) subscriptions",
      "!rss subscribe (url): Subscribe to that url",
      "!rss unsubscribe (id): Unsubscribe of that id",
      "!rss sync: Download now the updates and send it. Only sudo users can use this option."
   },
   patterns = {
      "^!rss$",
      "^!rss (subscribe) (https?://[%w-_%.%?%.:/%+=&]+)$",
      "^!rss (sub) (https?://[%w-_%.%?%.:/%+=&]+)$",
      "^!rss (unsubscribe) (%d+)$",
      "^!rss (uns) (%d+)$",
      "^!rss (sync)$"
   },
   run = run,
   cron = cron
}
