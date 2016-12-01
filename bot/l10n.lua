do
  l10n = setmetatable({
    curLocalization={},
    setLocale = function() end,
  }, 
  {__call = function (tbl, src) 
    if type(src) == 'string' then
      return (tbl.curLocalization[src] or src);
    end;
  end});
end