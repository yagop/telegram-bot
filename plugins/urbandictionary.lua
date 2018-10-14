do

  local function get_udescription(msg, matches)
    local url = 'http://api.urbandictionary.com/v0/define?term=' .. URL.escape(matches)

    local jstr, res = http.request(url)
    if res ~= 200 then
      send_message(msg, '<b>Connection error</b>', 'html')
      return
    end

    local jdat = json:decode(jstr)
    if jdat.result_type == 'no_results' then
      send_message(msg, "There aren't any definitions for <i>" .. matches .. "</i> yet.", 'html')
      return
    end

    local output = jdat.list[1].definition:trim()
    if string.len(jdat.list[1].example) > 0 then
      output = output .. '\n\n' .. jdat.list[1].example:trim()
    end

    send_message(msg, output, nil)
  end

  local function ud_by_reply(extra, success, result)
    if extra.to.peer_id == result.to.peer_id then
      get_udescription(result, result.text)
    else
      reply_msg(extra.id, "Sorry, I can't resolve a username from an old message", ok_cb, true)
    end
  end

  local function run(msg, matches)
    if msg.reply_id then
      if matches[1] == 'urbandictionary' or matches[1] == 'ud' or  matches[1] == 'urban' then
        get_message(msg.reply_id, ud_by_reply, msg)
      end
    else
      if msg.reply_to_message then
        get_udescription(msg, msg.reply_to_message.text)
      else
        get_udescription(msg, matches[1])
      end
    end
  end

  return {
    description = 'Returns a definition from Urban Dictionary.',
    usage = {
      '<code>!ud [query]</code>',
      '<code>!urban [query]</code>',
      '<code>!urbandictionary [query]</code>',
      'Returns a <code>[query]</code> definition from urbandictionary.com',
      '<b>Example</b>: <code>!ud fam</code>',
      '',
      '<code>!ud</code>',
      '<code>!urban</code>',
      '<code>!urbandictionary</code>',
      'By reply. Returns a <code>[query]</code> definition from urbandictionary.com',
      'The <code>[query]</code> is the replied message text.'
    },
    patterns = {
      '^!(urbandictionary)$',
      '^!(ud)$',
      '^!(urban)$',
      '^!urbandictionary (.+)$',
      '^!ud (.+)$',
      '^!urban (.+)$'
    },
    run = run
  }

end
