do

  local function regex(msg, text)
    local patterns = msg.text:match('s/.*')
    local m1, m2 = patterns:match('^s/(.-)/(.-)/?$')

    if not m2 or m2:match('\n') then
      return
    end

    local substring = text:gsub(m1, m2)

    send_message(msg, '<b>Did you mean:</b>\n"' .. substring:sub(1, 4000) .. '"', 'html')
  end

  local function patterns_by_reply(extra, success, result)
    local text = result.text or ''
    regex(extra, text)
  end

  local function run(msg, matches)
    if msg.reply_id then
      get_message(msg.reply_id, patterns_by_reply, msg)
    end
    if msg.from.api and msg.reply_to_message then
      regex(msg, msg.reply_to_message.text)
    end
  end

  return {
    description = 'Replace patterns in a message.',
    usage = {
      '<code>/s/from/to/</code>',
      '<code>/s/from/to</code>',
      '<code>s/from/to</code>',
      '<code>!s/from/to/</code>',
      '<code>!s/from/to</code>',
      'Replace <code>from</code> with <code>to</code>'
    },
    patterns = {
      '^/?s/.-/.-/?$',
      '^!s/.-/.-/?$'
    },
    run = run
  }

end
