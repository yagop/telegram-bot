do

  local function run(msg, matches)
    local base = 'http://dogr.io/'
    local dogetext = URL.escape(matches[1])
    local dogetext = string.gsub(dogetext, '%%2f', '/')
    local url = base .. dogetext .. '.png?split=false&.png'
    local urlm = 'https?://[%%%w-_%.%?%.:/%+=&]+'

    if string.match(url, urlm) == url then
      bot_sendMessage(get_receiver_api(msg), '[doge](' .. url .. ')', false, msg.id, 'markdown')
    else
      print("Can't build a good URL with parameter " .. matches[1])
    end
  end

  return {
    description = 'Create a doge image with you words.',
    usage = {
      '<code>!dogify (your/words/with/slashes)</code>',
      '<code>!doge (your/words/with/slashes)</code>',
      'Create a doge with the image and words.',
      '<b>Example</b>: <code>!doge wow/merbot/soo/cool</code>',
    },
    patterns = {
      '^!dogify (.+)$',
      '^!doge (.+)$',
    },
    run = run
   }

end