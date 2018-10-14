do

  local function get_9GAG()
    local url = 'http://api-9gag.herokuapp.com/'
    local b,c = http.request(url)

    if c ~= 200 then
      return nil
    end

    local gag = json:decode(b)
    -- random max json table size
    local i = math.random(#gag)
    local link_image = gag[i].src
    local title = gag[i].title

    if link_image:sub(0,2) == '//' then
      link_image = msg.text:sub(3,-1)
    end

    return link_image, title
  end

  local function run(msg, matches)
    local url, title = get_9GAG()
    local gag_file = '/tmp/gag.jpg'
    local g_file = ltn12.sink.file(io.open(gag_file, 'w'))
    http.request {
        url = url,
        sink = g_file,
      }

    if msg.from.api then
      bot_sendPhoto(get_receiver_api(msg), gag_file, nil, true, msg.id)
    else
      reply_photo(msg.id, gag_file, ok_cb, true)
    end
  end

  return {
    description = '9GAG for Telegram',
    usage = {
      '<code>!9gag</code>',
      'Send random image from 9gag',
    },
    patterns = {
      '^!9gag$'
    },
    run = run
  }

end
