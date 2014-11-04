
function run(msg, matches)
	file = download_to_file(matches[1])
    send_document(get_receiver(msg), file, ok_cb, false)
end

return {
    description = "from gif URL downloads it and sends to origin", 
    usage = "",
    patterns = {
    	"(https?://[%w-_%.%?%.:/%+=&]+.gif)$"
    }, 
    run = run 
}