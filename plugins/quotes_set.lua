do
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
    local quotes
    local phrase

    phrase   = string.match(msg.text, "!addquote (.+)")
    if (phrase == nil) then
      return "Usage: !addquote quote"
    end

    if quotes_table == nil then
      quotes_table = {}
    end

    if quotes_table[to_id] == nil then
      print ('New quote key to_id: '..to_id)
      quotes_table[to_id] = {}
    end

    quotes = quotes_table[to_id]
    quotes[#quotes+1] = phrase

    serialize_to_file(quotes_table, quotes_file)

    return "done!"
  end

  function run(msg, matches)
    quotes_table = read_quotes_file()
    return save_quote(msg)
  end

  return {
    description = "Save quote",
    usage       = "!addquote (quote)",
    patterns    = {"^!addquote (.+)$"},
    run = run
  }
end
