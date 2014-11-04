
function send_image_from_url (msg)
	last = string.get_last_word(msg.text)
	file = download_to_file(last)
	print("I will send the image " .. file)
	send_photo(get_receiver(msg), file, ok_cb, false)
end

function run(msg, matches)
	send_image_from_url(msg)
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