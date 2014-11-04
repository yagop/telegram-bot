
function send_youtube_thumbnail(msg, yt_code)
    yt_thumbnail = "http://img.youtube.com/vi/".. yt_code .."/hqdefault.jpg"
    file = download_to_file(yt_thumbnail)
    send_photo(get_receiver(msg), file, ok_cb, false)
end

function run(msg, matches)
	send_youtube_thumbnail(msg, matches[1])
end

return {
    description = "sends YouTube image", 
    usage = "",
    patterns = {
    	"youtu.be/([A-Za-z0-9-]+)",
    	"youtube.com/watch%?v=([A-Za-z0-9-]+)",
    }, 
    run = run 
}