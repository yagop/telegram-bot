do

  local helpers = require 'OAuth.helpers'
  local base = 'https://screenshotmachine.com/'
  local url = base .. 'processor.php'

  local function get_webshot_url(param)
    local response_body = {}
    local request_constructor = {
      url = url,
      method = 'GET',
      sink = ltn12.sink.table(response_body),
      headers = {
        referer = base,
        dnt = '1',
        origin = base,
        ['User-Agent'] = 'Mozilla/5.0 (X11; Linux x86_64; rv:47.0) Gecko/20100101 Firefox/47.0'
      },
      redirect = false
    }
    local arguments = {
      urlparam = param,
      size = 'FULL'
    }

    request_constructor.url = url .. '?' .. helpers.url_encode_arguments(arguments)

    local ok, response_code, response_headers, response_status_line = https.request(request_constructor)

    if not ok or response_code ~= 200 then
      return nil
    end

    local response = table.concat(response_body)

    return string.match(response, "href='(.-)'")
  end

  local function run(msg, matches)
    local find = get_webshot_url(matches[1])

    if find then
      local imgurl = base .. find
      local receiver = get_receiver(msg)
      --send_photo_from_url(receiver, imgurl)
      local webshotimg = download_to_file(imgurl, nil)

      if msg.from.api then
        bot_sendPhoto(get_receiver_api(msg), webshotimg, nil, true, msg.id)
      else
        reply_photo(msg.id, webshotimg, ok_cb, true)
      end
    end
  end

  return {
    description = 'Send an screenshot of a website.',
    usage = {
      '<code>!webshot [url]</code>',
      'Take an screenshot of the <code>[url]</code> and send it back to you.'
    },
    patterns = {
      '^!webshot (https?://[%w-_%.%?%.:/%+=&]+)$',
    },
    run = run
  }

end
