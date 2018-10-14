-- Implement a command !time [area] which uses
-- 2 Google APIs to get the desired result:
--  1. Geocoding to get from area to a lat/long pair
--  2. Timezone to get the local time in that lat/long location

do

  -- Globals
  -- If you have a google api key for the geocoding/timezone api
  local api_key  = nil
  local dateFormat = '%A, %F %T'

  -- Need the utc time for the google api
  local function utctime()
    return os.time(os.date('!*t'))
  end

  -- Use timezone api to get the time in the lat,
  -- Note: this needs an API key
  local function get_time(lat, lng)
    local api = 'https://maps.googleapis.com/maps/api/timezone/json?'

    -- Get a timestamp (server time is relevant here)
    local timestamp = utctime()
    local parameters = 'location=' .. URL.escape(lat) .. ',' .. URL.escape(lng)
         .. '&timestamp=' .. URL.escape(timestamp)

    if api_key ~=nil then
      parameters = parameters .. '&key=' .. api_key
    end

    local res,code = https.request(api .. parameters)

    if code ~= 200 then
      return nil
    end

    local data = json:decode(res)

    if (data.status == 'ZERO_RESULTS') then
      return nil
    end
    if (data.status == 'OK') then
      -- Construct what we want
      -- The local time in the location is: timestamp + rawOffset + dstOffset
      local localTime = timestamp + data.rawOffset + data.dstOffset
      return localTime, data.timeZoneId
    end
    return localTime
  end

  local function getformattedLocalTime(msg, area)
    if area == nil then
      send_message(msg, 'The time in nowhere is never.', 'html')
    end

    local coordinats, code = get_coords(msg, area)

    if not coordinats then
      send_message(msg, 'It seems that in "<b>' .. area .. '</b>" they do not have a concept of time.', 'html')
      return
    end

    local lat = coordinats.lat
    local long = coordinats.lon
    local localTime, timeZoneId = get_time(lat, long)

    send_message(msg, 'The local time in <b>' .. area .. ' (' .. timeZoneId .. ')</b> is:\n'
         ..  '<b>'  ..  os.date(dateFormat,localTime)  ..  '</b>', 'html')
  end

  local function run(msg, matches)
    return getformattedLocalTime(msg, matches[1])
  end

  return {
    description = 'Displays the local time in an area',
    usage = {
      '<code>!time [area]</code>',
      'Displays the local time in that <code>[area]</code>',
      '<b>Example</b>: <code>!time yogyakarta</code>',
    },
    patterns = {
      '^!time (.*)$'
    },
    run = run
  }

end

