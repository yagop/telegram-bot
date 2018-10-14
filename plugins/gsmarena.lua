--[[
Get Bing search API from from https://datamarket.azure.com/dataset/bing/search
Set the key by: !setapi bing [bing_api_key] or manually inserted into config.lua
--]]

do

  local mime = require('mime')
  local function get_galink(msg, query)
    local burl = "https://api.datamarket.azure.com/Data.ashx/Bing/Search/Web?Query=%s&$format=json&$top=1"
    local burl = burl:format(URL.escape("'site:gsmarena.com intitle:" .. query .. "'"))
    local resbody = {}
    local bang, bing, bung = https.request{
        url = burl,
        headers = { ["Authorization"] = "Basic " .. mime.b64(":" .. _config.api_key.bing) },
        sink = ltn12.sink.table(resbody),
    }
    local dat = json:decode(table.concat(resbody))
    local jresult = dat.d.results

    if next(jresult) ~= nil then
      return jresult[1].Url
    end
  end

  local function run(msg, matches)
    local phone = get_galink(msg, matches[2])
    local slug = phone:gsub('^.+/', '')
    local slug = slug:gsub('.php', '')
    local ibacor = 'http://ibacor.com/api/gsm-arena?view=product&slug='
    local res, code = http.request(ibacor .. slug)
    local gsm = json:decode(res)
    local phdata = {}

    if gsm == nil or gsm.status == 'error' or next(gsm.data) == nil then
      send_message(msg, '<b>No phones found!</b>\n'
          .. 'Request must be in the following format:\n'
          .. '<code>!gsm brand type</code>', 'html')
      return
    end
    if not gsm.data.platform then
      gsm.data.platform = {}
    end
    if gsm.data.launch.status == 'Discontinued' then
      launch = gsm.data.launch.status .. '. Was announced in ' .. gsm.data.launch.announced
    else
      launch = gsm.data.launch.status
    end
    if gsm.data.platform.os then
      phdata[1] = '<b>OS</b>: ' .. gsm.data.platform.os
    end
    if gsm.data.platform.chipset then
      phdata[2] = '<b>Chipset</b>: ' .. gsm.data.platform.chipset
    end
    if gsm.data.platform.cpu then
      phdata[3] = '<b>CPU</b>: ' .. gsm.data.platform.cpu
    end
    if gsm.data.platform.gpu then
      phdata[4] = '<b>GPU</b>: ' .. gsm.data.platform.gpu
    end
    if gsm.data.camera.primary then
      local phcam = '<b>Camera</b>: ' .. gsm.data.camera.primary:gsub(',.*$', '') .. ', ' .. (gsm.data.camera.video or '')
      phdata[5] = phcam:gsub(', check quality', '')
    end
    if gsm.data.memory.internal then
      phdata[6] = '<b>RAM</b>: ' .. gsm.data.memory.internal
    end

    local gadata = table.concat(phdata, '\n')
    local title = '<b>' .. gsm.title .. '</b>\n\n'
    local dimensions = gsm.data.body.dimensions:gsub('%(.-%)', '')
    local display = gsm.data.display.size:gsub(' .*$', '"') .. ', '
        .. gsm.data.display.resolution:gsub('%(.-%)', '')
    local output = title .. '<b>Status</b><a href="' .. gsm.img .. '">:</a> ' .. launch .. '\n'
        .. '<b>Dimensions</b>: ' .. dimensions .. '\n'
        .. '<b>Weight</b>: ' .. gsm.data.body.weight:gsub('%(.-%)', '') .. '\n'
        .. '<b>SIM</b>: ' .. gsm.data.body.sim .. '\n'
        .. '<b>Display</b>: ' .. display .. '\n'
        .. gadata
        .. '\n<b>MC</b>: ' .. gsm.data.memory.card_slot .. '\n'
        .. '<b>Battery</b>: ' .. gsm.data.battery._empty_:gsub('battery', '') .. '\n'
        .. '<a href="' .. phone .. '">More on gsmarena.com ...</a>'

    bot_sendMessage(get_receiver_api(msg), output:gsub('<br>', ''), false, msg.id, 'html')
  end

--------------------------------------------------------------------------------

  return {
    description = 'Returns mobile phone specification.',
    usage = {
      '<code>!phone [phone]</code>',
      '<code>!gsm [phone]</code>',
      'Returns <code>phone</code> specification.',
      '<b>Example</b>: <code>!gsm xiaomi mi4c</code>',
    },
    patterns = {
      '^!(phone) (.*)$',
      '^!(gsmarena) (.*)$',
      '^!(gsm) (.*)$'
    },
    run = run
  }

end
