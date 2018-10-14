do

  local function run(msg, matches)
    local omdbapi = 'http://www.omdbapi.com/?plot=full&r=json'
    local movietitle = matches[1]

    if matches[1]:match(' %d%d%d%d$') then
      local movieyear = matches[1]:match('%d%d%d%d$')
      movietitle = matches[1]:match('^.+ ')
      omdbapi = omdbapi .. '&y=' .. movieyear
    end

    local success, code = http.request(omdbapi .. '&t=' .. URL.escape(movietitle))

    if success then
      jomdb = json:decode(success)
    end

    if jomdb.Response == 'False' then
      send_message(msg, '<b>' .. jomdb.Error .. '</b>', 'html')
      return
    end

    if not jomdb then
      send_message(msg, '<b>' .. json:decode(code) .. '</b>', 'html')
      return
    end

    local omdb = '<b>' .. jomdb.Title .. '</b>\n\n'
        .. '<b>Year</b><a href="' .. jomdb.Poster .. '">:</a> ' .. jomdb.Year .. '\n'
        .. '<b>Rated</b>: ' .. jomdb.Rated .. '\n'
        .. '<b>Runtime</b>: ' .. jomdb.Runtime .. '\n'
        .. '<b>Genre</b>: ' .. jomdb.Genre .. '\n'
        .. '<b>Director</b>: ' .. jomdb.Director .. '\n'
        .. '<b>Writer</b>: ' .. jomdb.Writer .. '\n'
        .. '<b>Actors</b>: ' .. jomdb.Actors .. '\n'
        .. '<b>Country</b>: ' .. jomdb.Country .. '\n'
        .. '<b>Awards</b>: ' .. jomdb.Awards .. '\n'
        .. '<b>Plot</b>: ' .. jomdb.Plot .. '\n\n'
        .. '<a href="http://imdb.com/title/' .. jomdb.imdbID .. '">IMDB</a>:\n'
        .. '<b>Metascore</b>: ' .. jomdb.Metascore .. '\n'
        .. '<b>Rating</b>: ' .. jomdb.imdbRating .. '\n'
        .. '<b>Votes</b>: ' .. jomdb.imdbVotes .. '\n\n'

    bot_sendMessage(get_receiver_api(msg), omdb, false, msg.id, 'html')
  end

  return {
    description = 'The Open Movie Database plugin for Telegram.',
    usage = {
      '<code>!imdb [movie]</code>',
      '<code>!omdb [movie]</code>',
      'Returns IMDb entry for <code>[movie]</code>',
      '<b>Example</b>: <code>!imdb the matrix</code>',
      '',
      '<code>!imdb [movie] [year]</code>',
      '<code>!omdb [movie] [year]</code>',
      'Returns IMDb entry for <code>[movie]</code> that was released in <code>[year]</code>',
      '<b>Example</b>: <code>!imdb the matrix 2003</code>',
    },
    patterns = {
      '^![io]mdb (.+)$',
    },
    run = run
  }

end
