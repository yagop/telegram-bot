do

local BASE_LNM_URL = 'http://api.lyricsnmusic.com/songs'
local LNM_APIKEY = '1f5ea5cf652d9b2ba5a5118a11dba5'

local BASE_LYRICS_URL = 'http://api.chartlyrics.com/apiv1.asmx/SearchLyricDirect'

local function getInfo(query)
  print('Getting info of ' .. query)

  local url = BASE_LNM_URL..'?api_key='..LNM_APIKEY
    ..'&q='..URL.escape(query)

  local b, c = http.request(url)
  if c ~= 200 then
    return nil
  end

  local result = json:decode(b)
  local artist = result[1].artist.name
  local track = result[1].title
  return artist, track
end

local function getLyrics(query)

  local artist, track = getInfo(query)
  if artist and track then
    local url = BASE_LYRICS_URL..'?artist='..URL.escape(artist)
      ..'&song='..URL.escape(track)

    local b, c = http.request(url)
    if c ~= 200 then
      return nil
    end

    local xml = require("xml")
    local result = xml.load(b)

    if not result then
      return nil
    end

    if xml.find(result, 'LyricSong') then
      track = xml.find(result, 'LyricSong')[1]
    end

    if xml.find(result, 'LyricArtist') then
      artist = xml.find(result, 'LyricArtist')[1]
    end

    local lyric
    if xml.find(result, 'Lyric') then
      lyric = xml.find(result, 'Lyric')[1]
    else
      lyric = nil
    end

    local cover
    if xml.find(result, 'LyricCovertArtUrl') then
      cover = xml.find(result, 'LyricCovertArtUrl')[1]
    else
      cover = nil
    end

    return artist, track, lyric, cover

  else
    return nil
  end

end


local function run(msg, matches)
  local artist, track, lyric, cover = getLyrics(matches[1])
  if track and artist and lyric then
    if cover then
      local receiver = get_receiver(msg)
      send_photo_from_url(receiver, cover)
    end
    return '🎵 ' .. artist .. ' - ' .. track .. ' 🎵\n----------\n' .. lyric
  else
    return 'Oops! Lyrics not found or something like that! :/'
  end
end

return {
  description = 'Getting lyrics of a song',
  usage = '!lyrics [track or artist - track]: Search and get lyrics of the song',
  patterns = {
     '^!lyrics? (.*)$'
  },
  run = run
}

end
