
function run(msg, matches)
	file = download_to_file(matches[1])
    print("I will send the image " .. file)
    send_photo(get_receiver(msg), file, ok_cb, false)
end

return {
    description = "When user sends image URL (ends with png, jpg, jpeg) download and send it to origin.", 
    usage = "",
    patterns = {
    	"(https?://[%w-_%.%?%.:/%+=&]+.png)$",
    	"(https?://[%w-_%.%?%.:/%+=&]+.jpg)$",
    	"(https?://[%w-_%.%?%.:/%+=&]+.jpeg)$",
    }, 
    run = run 
}