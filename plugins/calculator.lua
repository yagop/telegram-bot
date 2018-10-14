-- Function reference: http://mathjs.org/docs/reference/functions/categorical.html

do

  local function mathjs(msg, exp)
    local result = http.request('http://api.mathjs.org/v1/?expr=' .. URL.escape(exp))

    if not result then
      result = 'Unexpected error\nIs api.mathjs.org up?'
    end

    send_message(msg, '<b>' .. result .. '</b>', 'html')
  end

  local function run(msg, matches)
    mathjs(msg, matches[1])
  end

  return {
    description = "Calculate math expressions with mathjs.org API.",
    usage = {
      '<code>!calc [expression]</code>',
      '<code>!calculator [expression]</code>',
      'Evaluates the expression and sends the result.',
    },
    patterns = {
      "^!calc (.*)$",
      "^!calculator (.*)"
    },
    run = run
  }

end
