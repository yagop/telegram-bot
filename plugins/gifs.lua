function send_file_from_url (msg, url)
    last = string.get_last_word(ul)
    file = download_to_file(last)
    send_document(get_receiver(msg), file, ok_cb, false)
end

function run(msg, matches)
	send_file_from_url(msg, matches[1])
end

return {
    description = "from gif URL downloads it and sends to origin", 
    usage = "",
    patterns = {
    	"(https?://[%w-_%.%?%.:/%+=&]+.gif)$"
    }, 
    run = run 
}