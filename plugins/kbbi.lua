do

  local tag_list = {
    ['&#183;'] = '·',
    ['<sup>.-/sup>'] = '',
    ['<br/>'] = '\n',
    ['\\/'] = '/',
    ['—'] = '--',
    [' <b>1'] = '\n<b>1',
    [' <b>2'] = '\n<b>2',
    [' <b>3'] = '\n<b>3',
    [' <b>4'] = '\n<b>4',
    [' <b>5'] = '\n<b>5',
    [' <b>6'] = '\n<b>6',
    [' <b>7'] = '\n<b>7',
    [' <b>8'] = '\n<b>8',
    [' <b>9'] = '\n<b>9',
    [' <b>10'] = '\n<b>10'
  }

  local function cleanup_tag(html)
    for k,v in pairs(tag_list) do
      html = html:gsub(k, v)
    end
    return html
  end

  local function run(msg, matches)
    local webkbbi = 'http://kbbi.web.id/'
    local lema = matches[1]

    if #matches == 2 then
      lema = matches[1] .. '+' .. matches[2]
    end

    local res, code = http.request(webkbbi .. lema .. '/ajax_0')

    if res == '' then
      send_message(msg, 'Tidak ada arti kata "<b>' .. lema .. '</b>" di kbbi.web.id' , 'html')
      return
    end

    if #matches == 2 then
      kbbi_desc = res:match('<b>%-%- ' .. matches[2] .. '.-<br\\/>')
      title = '<a href="' .. webkbbi .. lema .. '">' .. matches[1] .. '</a>\n\n'
    else
      local grabbedlema = res:match('{"x":1,"w":.-}')
      local jlema = json:decode(grabbedlema)
      title = '<a href="' .. webkbbi .. lema .. '">' .. jlema.w .. '</a>\n\n'

      if jlema.d:match('<br/>') then
        kbbi_desc = jlema.d:match('^.-<br/>')
      else
        kbbi_desc = jlema.d
      end
    end
    print(cleanup_tag(title .. kbbi_desc))
    bot_sendMessage(get_receiver_api(msg), cleanup_tag(title .. kbbi_desc), true, msg.id, 'html')
  end

--------------------------------------------------------------------------------

  return {
    description = 'Kamus Besar Bahasa Indonesia dari http://kbbi.web.id.',
    usage = {
      '<code>!kbbi [lema]</code>',
      'Menampilkan arti dari <code>[lema]</code>'
    },
    patterns = {
      '^!kbbi (%w+)$',
      '^!kbbi (%w+) (%w+)$'
    },
    run = run
  }

end
