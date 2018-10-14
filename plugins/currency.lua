do

  local function get_word(s, i)
    s = s or ''
    i = i or 1
    local t = {}

    for w in s:gmatch('%g+') do
      table.insert(t, w)
    end

    return t[i] or false
  end

  local function run(msg, matches)
    local input = msg.text:upper()

    if not input:match('%a%a%a TO %a%a%a') then
      send_message(msg, '<b>Example:</b> <code>!cash 5 USD to IDR</code>', 'html')
      return
    end

    local from = input:match('(%a%a%a) TO')
    local to = input:match('TO (%a%a%a)')
    local amount = get_word(input, 2)
    local amount = tonumber(amount) or 1
    local result = 1
    local url = 'https://www.google.com/finance/converter'

    if from ~= to then
      local url = url .. '?from=' .. from .. '&to=' .. to .. '&a=' .. amount
      local str, res = https.request(url)

      if res ~= 200 then
        send_message(msg, '<b>Connection error</b>', 'html')
        return
      end

      str = str:match('<span class=bld>(.*) %u+</span>')

      if not str then
        send_message(msg, '<b>Connection error</b>', 'html')
        return
      end

      result = string.format('%.2f', str):gsub('%.', ',')
    end

    local headerapi = '<b>' .. amount .. ' ' .. from .. ' = ' .. group_into_three(result) .. ' ' .. to .. '</b>\n\n'
    local source = 'Source: Google Finance\n<code>' .. os.date('%F %T %Z') .. '</code>'

    send_message(msg, headerapi .. source, 'html')
  end

--------------------------------------------------------------------------------

  return {
    description = 'Returns (Google Finance) exchange rates for various currencies.',
    usage = {
      '<code>!cash [amount] [from] to [to]</code>',
      'Example:',
      '  *  <code>!cash 5 USD to EUR</code>',
      '  *  <code>!currency 1 usd to idr</code>',
    },
    patterns = {
      '^!cash (.*)$',
      '^!currency (.*)$',
    },
    run = run
  }

end
