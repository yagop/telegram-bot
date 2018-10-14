-- dependency: whois
-- install on your system, i.e sudo aptitude install whois

do

  local whofile = '/tmp/whois.txt'

  local function whoinfo()
    local file = io.open(whofile, 'r')
    local content = file:read "*a"
    file:close()
    return content:sub(1, 4000)
  end

  local function run(msg, matches)
    local result = os.execute('whois ' .. matches[1] .. ' > ' .. whofile)

    if not result then
      if whoinfo():match('no match') then
        send_message(msg, '<b>No match for</b> ' .. matches[1] .. '\n'
            .. '* type the URL correctly\n'
            .. '* exclude http(s) and www from the URL.', 'html')
      elseif not os.execute('which whois') then
        send_message(msg, '<b>sh: 1: whois: not found</b>.\n'
          .. 'Please install <code>whois</code> package on your system.', 'html')
      end
      return
    end

    if matches[2] then
      if matches[2] == 'txt' then
        if msg.from.api then
          bot_sendDocument(get_receiver_api(msg), whofile, nil, true, msg.id)
        else
          reply_file(msg.id, whofile, ok_cb, true)
        end
      end
      if matches[2] == 'pm' and is_chat_msg(msg) then
        bot_sendMessage(msg.from.peer_id, whoinfo(), true, nil, nil)
      end
      if matches[2] == 'pmtxt' and is_chat_msg(msg) then
        bot_sendDocument(msg.from.peer_id, whofile, nil, true, nil)
      end
    else
      send_message(msg, whoinfo(), nil)
    end
  end

  return {
    description = 'Whois lookup.',
    usage = {
      '<code>!whois [url]</code>',
      'Returns whois lookup for <code>[url]</code>',
      '',
      '<code>!whois [url] txt</code>',
      'Returns whois lookup for <code>[url]</code> and then send as text file.',
      '',
      '<code>!whois [url] pm</code>',
      'Returns whois lookup for <code>[url]</code> into requester PM.',
      '',
      '<code>!whois [url] pmtxt</code>',
      'Returns whois lookup file for <code>[url]</code> and then send into requester PM.',
    },
    patterns = {
      '^!whois (%g+)$',
      '^!whois (%g+) (txt)$',
      '^!whois (%g+) (pm)$',
      '^!whois (%g+) (pmtxt)$'
    },
    run = run
  }

end
