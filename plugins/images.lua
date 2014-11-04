
function run(msg, matches)
	file = download_to_file(matches[1])
    print("I will send the image " .. file)
    send_photo(get_receiver(msg), file, ok_cb, false)
end

return {
    description = "from image URL downloads it and sends to origin", 
    usage = "",
    patterns = {
    	"(https?://[%w-_%.%?%.:/%+=&]+.png)$",
    	"(https?://[%w-_%.%?%.:/%+=&]+.jpg)$",
    	"(https?://[%w-_%.%?%.:/%+=&]+.jpeg)$",
    }, 
    run = run 
}