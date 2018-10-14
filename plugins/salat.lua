do

  local base_api = 'http://muslimsalat.com'
  local calculation = {
    [1] = 'Egyptian General Authority of Survey',
    [2] = 'University Of Islamic Sciences, Karachi (Shafi)',
    [3] = 'University Of Islamic Sciences, Karachi (Hanafi)',
    [4] = 'Islamic Circle of North America',
    [5] = 'Muslim World League',
    [6] = 'Umm Al-Qura',
    [7] = 'Fixed Isha'
  }

  local function get_time(lat, lng)
    local api = 'https://maps.googleapis.com/maps/api/timezone/json?'
    local timestamp = os.time(os.date('!*t'))
    local parameters = 'location=' .. URL.escape(lat) .. ',' .. URL.escape(lng)
        .. '&timestamp=' .. URL.escape(timestamp)
    local res,code = https.request(api .. parameters)

    if code ~= 200 then
      return nil
    end

    local data = json:decode(res)

    if (data.status == 'ZERO_RESULTS') then
      return nil
    end
    if (data.status == 'OK') then
      return timestamp + data.rawOffset + data.dstOffset
    end
  end

  function totwentyfour(twelvehour)
    local hour, minute, meridiem = string.match(twelvehour, '^(.-):(.-) (.-)$')
    local hour = tonumber(hour)
    if (meridiem == 'am') and (hour == 12) then
      hour = 0
    elseif (meridiem == 'pm') and (hour < 12) then
      hour = hour + 12
    end

    if hour < 10 then
      hour = '0' .. hour
    end

    return (hour .. ':' .. minute)
  end

  function run(msg, matches)
    check_api_key(msg, 'muslimsalat', 'http://muslimsalat.com/panel/signup.php')

    if matches[1] == 'setapikey muslimsalat' and is_sudo(msg.from.peer_id) then
      _config.api_key.muslimsalat = matches[2]
      save_config()
      send_message(msg, 'Muslim salat api key has been saved.', 'html')
      return
    end

    local area = matches[1]
    local method = 5
    local notif = ''
    local url = base_api .. '/' .. URL.escape(area) .. '.json'

    if matches[2] and matches[1]:match('%d') then
      local c_method = tonumber(matches[1])

      if c_method == 0 or c_method > 7 then
        local text = '<b>Calculation method is out of range</b>\n'
                .. 'Consult <code>!help salat</code>'
        send_message(msg, text, 'html')
        return
      else
        method = c_method
        url = base_api .. '/' .. URL.escape(matches[2]) .. '.json'
        notif = '\n\n<b>Method:</b> ' .. calculation[method]
        area = matches[2]
      end
    end

    local res, code = http.request(url .. '/' .. method .. '?key=' .. _config.api_key.muslimsalat)

    if code ~= 200 then
      send_message(msg, '<b>Error</b>: <code>' .. code .. '</code>', 'html')
      return
    end

    local salat = json:decode(res)
    local localTime = get_time(salat.latitude, salat.longitude)

    if salat.title == '' then
      salat_area = area .. ', ' .. salat.country
    else
      salat_area = salat.title
    end

    local is_salat_time = '<b>Salat time</b>\n\n'
        .. '<a href="' .. salat.link .. '">' .. salat_area .. '</a>\n\n'
        .. '<code>Time    : ' .. os.date('%T', localTime) .. '\n'
        .. 'Qibla   : ' .. salat.qibla_direction .. '°\n\n'
        .. 'Fajr    : ' .. totwentyfour(salat.items[1].fajr) .. '\n'
        .. 'Sunrise : ' .. totwentyfour(salat.items[1].shurooq) .. '\n'
        .. 'Dhuhr   : ' .. totwentyfour(salat.items[1].dhuhr) .. '\n'
        .. 'Asr     : ' .. totwentyfour(salat.items[1].asr) .. '\n'
        .. 'Maghrib : ' .. totwentyfour(salat.items[1].maghrib) .. '\n'
        .. 'Isha    : ' .. totwentyfour(salat.items[1].isha) .. '</code>' .. notif

    bot_sendMessage(get_receiver_api(msg), is_salat_time, true, msg.id, 'html')
  end

  return {
    description = 'Returns todays prayer times.',
    usage = {
      sudo = {
        '<code>!setapikey muslimsalat [api_key]</code>',
        'Set Muslim Salat API key.'
      },
      user = {
        '<code>!salat [area]</code>',
        'Returns todays prayer times for that area',
        '<b>Example</b>: <code>!salat bandung</code>',
        '',
        '<code>!salat [method] [area]</code>',
        'Returns todays prayer times for that area calculated by <code>[method]</code>:',
        '<b>1</b> = Egyptian General Authority of Survey',
        '<b>2</b> = University Of Islamic Sciences, Karachi (Shafi)',
        '<b>3</b> = University Of Islamic Sciences, Karachi (Hanafi)',
        '<b>4</b> = Islamic Circle of North America',
        '<b>5</b> = Muslim World League',
        '<b>6</b> = Umm Al-Qura',
        '<b>7</b> = Fixed Isha',
        '<b>Example</b>: <code>!salat 2 denpasar</code>',
      },
    },
    patterns = {
      '^!salat (%a.*)$',
      '^!salat (%d) (%a.*)$',
      '^!(setapikey muslimsalat) (.*)$'
    },
    run = run
  }

end

