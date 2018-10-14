do

  -- See https://bitcoinaverage.com/api
  local function run(msg, matches)
    local base_url = 'https://api.bitcoinaverage.com/ticker/global/'
    local currency = 'USD'

    if matches[2] then
      currency = matches[2]:upper()
    end

    -- Do request on bitcoinaverage, the final / is critical!
    local res, code = https.request(base_url .. currency .. '/')

    if code ~= 200 then return nil end

    local data = json:decode(res)
    local ask = string.gsub(data.ask, '%.', ',')
    local bid = string.gsub(data.bid, '%.', ',')
    local index = '<b>BTC</b> in <b>' .. currency .. ':</b>\n'
        .. '• Buy: ' .. group_into_three(ask) .. '\n'
        .. '• Sell: ' .. group_into_three(bid)

    bot_sendMessage(get_receiver_api(msg), index, true, msg.id, 'html')
  end

  --------------------------------------------------------------------------------

  return {
    description = 'Displays the current Bitcoin price.',
    usage = {
      '<code>!btc</code>',
      'Displays Bitcoin price in USD',
      '',
      '<code>!btc [currency]</code>',
      'Displays Bitcoin price in <code>[currency]</code>',
      '<code>[currency]</code> is in <a href"https://en.wikipedia.org/wiki/ISO_4217">ISO 4217</a> format.',
      '',
    },
    patterns = {
      '^!(btc)$',
      '^!(btc) (%a%a%a)$',
    },
    run = run
  }

end