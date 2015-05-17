local quotes_file = './data/quotes.lua'
local quotes_table

function read_quotes_file()
    local f = io.open(quotes_file, "r+")

    if f == nil then
        print ('Created a new quotes file on '..quotes_file)
        serialize_to_file({}, quotes_file)
    else
        print ('Quotes loaded: '..quotes_file)
        f:close()
    end
    return loadfile (quotes_file)()
end

function save_quote(msg)
    local to_id = tostring(msg.to.id)

    if msg.text:sub(11):isempty() then
        return "Usage: !addquote quote"
    end

    if quotes_table == nil then
        quotes_table = {}
    end

    if quotes_table[to_id] == nil then
        print ('New quote key to_id: '..to_id)
        quotes_table[to_id] = {}
    end

    local quotes = quotes_table[to_id]
    quotes[#quotes+1] = msg.text:sub(11)

    serialize_to_file(quotes_table, quotes_file)

    return "done!"
end

function get_quote(msg)
    local to_id = tostring(msg.to.id)
    local quotes_phrases

    quotes_table = read_quotes_file()
    quotes_phrases = quotes_table[to_id]

    return quotes_phrases[math.random(1,#quotes_phrases)]
end

function run(msg, matches)
    if string.match(msg.text, "!quote$") then
        return get_quote(msg)
    elseif string.match(msg.text, "!addquote (.+)$") then
        quotes_table = read_quotes_file()
        return save_quote(msg)
    end
end

return {
    description = "Save quote",
    description = "Quote plugin, you can create and retrieve random quotes",
    usage = {
        "!addquote [msg]",
        "!quote",
    },
    patterns = {
        "^!addquote (.+)$",
        "^!quote$",
    },
    run = run
}
