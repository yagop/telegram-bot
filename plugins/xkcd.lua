do

  function get_last_id(msg)
    local res, code  = https.request('http://xkcd.com/info.0.json')

    if code ~= 200 then
      send_message(msg, '<b>HTTP ERROR</b>', 'html')
    end

    local data = json:decode(res)

    return data.num
  end

  function get_xkcd(msg, id)
    local res,code  = http.request('http://xkcd.com/' .. id .. '/info.0.json')

    if code ~= 200 then
      send_message(msg, '<b>HTTP ERROR</b>', 'html')
    end

    local data = json:decode(res)
    local link_image = data.img

    if link_image:sub(0,2) == '//' then
      link_image = msg.text:sub(3,-1)
    end

    return link_image, data.num, data.title, data.alt
  end

  function get_xkcd_random(msg)
    local last = get_last_id(msg)
    local i = math.random(1, last)
    return get_xkcd(msg, i)
  end

  function run(msg, matches)
    if matches[1] == 'xkcd' then
      url, num, title, alt = get_xkcd_random(msg)
    else
      url, num, title, alt = get_xkcd(msg, matches[1])
    end

    local relevantxkcd = '<a href="' .. url .. '">' .. title .. '</a>\n\n' .. alt .. '\n\n'

    bot_sendMessage(get_receiver_api(msg), relevantxkcd, false, msg.id, 'html')
  end

  return {
    description = 'Send comic images from xkcd',
    usage = {
      '<code>!xkcd</code>',
      'Send random xkcd image and title.',
      '',
      '<code>!xkcd (id)</code>',
      'Send an xkcd image and title.',
      '<b>Example</b>: <code>!xkcd 149</code>',
    },
    patterns = {
      '^!(xkcd)$',
      '^!xkcd (%d+)',
    },
    run = run
  }

end
