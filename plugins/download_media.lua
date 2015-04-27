local function callback(extra, success, result)
  if success then
    print('File downloaded to:', result)
  else
    print('Error downloading: '..extra)
  end
end

local function run(msg, matches)
  if msg.media then
    if msg.media.type == 'document' then
      load_document(msg.id, callback, msg.id)
    end
    if msg.media.type == 'photo' then
      load_photo(msg.id, callback, msg.id)
    end
    if msg.media.type == 'video' then
      load_video(msg.id, callback, msg.id)
    end
    if msg.media.type == 'audio' then
      load_audio(msg.id, callback, msg.id)
    end
  end
end

local function pre_process(msg)
  if not msg.text and msg.media then
    msg.text = '['..msg.media.type..']'
  end
  return msg
end

return {
  description = "When bot receives a media msg, download the media.",
  usage = "",
  run = run,
  patterns = {
    '%[(document)%]',
    '%[(photo)%]',
    '%[(video)%]',
    '%[(audio)%]'
  },
  pre_process = pre_process
}