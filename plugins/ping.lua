
function run(msg, matches)
    local receiver = get_receiver(msg)
    print('receiver: '..receiver)
    return "pong"
end

return {
    description = "bot sends pong", 
    usage = "!ping",
    patterns = {"^!ping$"}, 
    run = run 
}

