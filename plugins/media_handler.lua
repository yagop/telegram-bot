local function run(msg, matches)
  if msg.media then
    if msg.media.type == 'document' then
      print('Document file')
    end
    if msg.media.type == 'photo' then
      print('Photo file')
    end
    if msg.media.type == 'video' then
      print('Video file')
    end
    if msg.media.type == 'audio' then
      print('Audio file')
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
  description = "Media handler.",
  usage = "Bot media handler, no usage.",
  run = run,
  patterns = {
    '%[(document)%]',
    '%[(photo)%]',
    '%[(video)%]',
    '%[(audio)%]'
  },
  hide = true,
  pre_process = pre_process
}
