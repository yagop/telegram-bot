--[[
Get Bing search API from from https://datamarket.azure.com/dataset/bing/search
Set the key by: !setapi bing [bing_api_key] or manually inserted into config.lua
--]]

do

  local mime = require('mime')

  local function bingo(msg, burl, terms)
    local burl = burl:format(URL.escape("'" .. terms .. "'"))
    local limit = 5

    if not is_chat_msg(msg) then
      limit = 8
    end

    local resbody = {}
    local bang, bing, bung = https.request{
        url = burl .. '&$top=' .. limit,
        headers = { ["Authorization"] = "Basic " .. mime.b64(":" .. _config.api_key.bing) },
        sink = ltn12.sink.table(resbody),
    }
    local dat = json:decode(table.concat(resbody))
    local jresult = dat.d.results

    if next(jresult) == nil then
      send_message(msg, '<b>No Bing results for</b>: ' .. terms, 'html')
    else
      local reslist = {}
      for i = 1, #jresult do
        local result = jresult[i]
        reslist[i] = '<b>' .. i .. '</b>. '
            .. '<a href="' .. result.Url:gsub('[!]', '%%21') .. '">' .. result.Title .. '</a>'
      end

      local reslist = table.concat(reslist, '\n')
      local header = '<b>Bing results for</b> <i>' .. terms .. '</i> <b>:</b>\n'

      bot_sendMessage(get_receiver_api(msg), header .. reslist, true, msg.id, 'html')
    end
  end

  local function bing_by_reply(extra, success, result)
    local terms = result.text

    bingo(extra.msg, extra.burl, terms)
  end

  local function run(msg, matches)
    check_api_key(msg, 'bing', 'https://datamarket.azure.com/dataset/bing/search')

    if matches[1] == 'setapikey bing' and is_sudo(msg.from.peer_id) then
      _config.api_key.bing = matches[2]
      save_config()
      send_message(msg, 'Bing api key has been saved.', 'html')
      return
    end

    local burl = "https://api.datamarket.azure.com/Data.ashx/Bing/Search/Web?Query=%s&$format=json"

    if matches[1]:match('nsfw') then
      burl = burl .. '&Adult=%%27Off%%27'
    else
      burl = burl .. '&Adult=%%27Strict%%27'
    end

    if msg.reply_id then
      get_message(msg.reply_id, bing_by_reply, {msg=msg, burl=burl})
    else
      if msg.reply_to_message then
        bingo(msg, burl, msg.reply_to_message.text)
      else
        bingo(msg, burl, matches[2])
      end
    end
  end

--------------------------------------------------------------------------------

  return {
    description = 'Returns 5 (if group) or 8 (if private message) Bing results.\n'
        .. 'Safe search is enabled by default, use <code>!bnsfw</code> or <code>!bingnsfw</code> to disable it.',
    usage = {
      sudo = {
        '<code>!setapikey bing [api_key]</code>',
        'Set Bing API key.'
      },
      user = {
        '<code>!bing [terms]</code>',
        '<code>!b [terms]</code>',
        'Safe searches Bing',
        '',
        '<code>!bing</code>',
        '<code>!b</code>',
        'Safe searches Bing by reply. The search terms is the replied message text.',
        '',
        '<code>!bingnsfw [terms]</code>',
        '<code>!bnsfw [terms]</code>',
        'Searches Bing (include NSFW)',
        '',
        '<code>!bingnsfw</code>',
        '<code>!bnsfw</code>',
        'Searches Bing (include NSFW). The search terms is the replied message text.'
      },
    },
    patterns = {
      '^!(b)$', '^!(bing)$',
      '^!b(nsfw)$', '^!bing(nsfw)$',
      '^!(b) (.*)$', '^!(bing) (.*)$',
      '^!b(nsfw) (.*)$', '^!bing(nsfw) (.*)$',
      '^!(setapikey bing) (.*)$',
    },
    run = run
  }

end
