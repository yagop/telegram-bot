do

  local function run(msg, matches)
    check_api_key(msg, 'nasa_api', 'http://api.nasa.gov')

    if matches[1] == 'setapikey nasa_api' and is_sudo(msg.from.peer_id) then
      _config.api_key.nasa_api = matches[2]
      save_config()
      send_message(msg, 'NASA api key has been saved.', 'html')
      return
    end

    local apodate = '<b>' .. os.date("%F") .. '</b>\n\n'
    local url = 'https://api.nasa.gov/planetary/apod?api_key=' .. _config.api_key.nasa_api

    if matches[2] then
      if matches[2]:match('%d%d%d%d%-%d%d%-%d%d$') then
        url = url .. '&date=' .. URL.escape(matches[2])
        apodate = '<b>' .. matches[2] .. '</b>\n\n'
      else
        send_message(msg, '<b>Request must be in following format</b>:\n<code>!' .. matches[1] .. ' YYYY-MM-DD</code>', 'html')
        return
      end
    end

    local str, res = https.request(url)

    if res ~= 200 then
      send_message(msg, '<b>Connection error</b>', 'html')
      return
    end

    local jstr = json:decode(str)

    if jstr.error then
      send_message(msg, '<b>No results found</b>', 'html')
      return
    end

    local img_url = jstr.hdurl or jstr.url
    local apod = apodate .. '<a href="' .. img_url .. '">' .. jstr.title .. '</a>'

    if matches[1] == 'apodtext' then
      apod = apod .. '\n\n' .. jstr.explanation
    end

    if jstr.copyright then
      apod = apod .. '\n\n<i>Copyright: ' .. jstr.copyright .. '</i>'
    end

    bot_sendMessage(get_receiver_api(msg), apod, false, msg.id, 'html')
  end

  return {
    description = "Returns the NASA's Astronomy Picture of the Day.",
    usage = {
      sudo = {
        '<code>!setapikey nasa_api [api_key]</code>',
        'Set NASA APOD API key.'
      },
      user = {
        '<code>!apod</code>',
        'Returns the Astronomy Picture of the Day (APOD).',
        '',
        '<code>!apod YYYY-MM-DD</code>',
        'Returns the <code>YYYY-MM-DD</code> APOD.',
        '<b>Example</b>: <code>!apod 2016-08-17</code>',
        '',
        '<code>!apodtext</code>',
        'Returns the explanation of the APOD.',
        '',
        '<code>!apodtext YYYY-MM-DD</code>',
        'Returns the explanation of <code>YYYY-MM-DD</code> APOD.',
        '<b>Example</b>: <code>!apodtext 2016-08-17</code>',
        '',
      },
    },
    patterns = {
      '^!(apod)$',
      '^!(apodtext)$',
      '^!(apod) (%g+)$',
      '^!(apodtext) (%g+)$',
      '^!(setapikey nasa_api) (.*)$'
    },
    run = run
  }

end
