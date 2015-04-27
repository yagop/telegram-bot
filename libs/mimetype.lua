-- Thanks to https://github.com/catwell/lua-toolbox/blob/master/mime.types
do 

local mimetype = {}

-- TODO: Add more?
local types = {
  ["text/html"] = "html",
  ["text/css"] = "css",
  ["text/xml"] = "xml",
  ["image/gif"] = "gif",
  ["image/jpeg"] = "jpg",
  ["application/x-javascript"] = "js",
  ["application/atom+xml"] = "atom",
  ["application/rss+xml"] = "rss",
  ["text/mathml"] = "mml",
  ["text/plain"] = "txt",
  ["text/vnd.sun.j2me.app-descriptor"] = "jad",
  ["text/vnd.wap.wml"] = "wml",
  ["text/x-component"] = "htc",
  ["image/png"] = "png",
  ["image/tiff"] = "tiff",
  ["image/vnd.wap.wbmp"] = "wbmp",
  ["image/x-icon"] = "ico",
  ["image/x-jng"] = "jng",
  ["image/x-ms-bmp"] = "bmp",
  ["image/svg+xml"] = "svg",
  ["image/webp"] = "webp",
  ["application/java-archive"] = "jar",
  ["application/mac-binhex40"] = "hqx",
  ["application/msword"] = "doc",
  ["application/pdf"] = "pdf",
  ["application/postscript"] = "ps",
  ["application/rtf"] = "rtf",
  ["application/vnd.ms-excel"] = "xls",
  ["application/vnd.ms-powerpoint"] = "ppt",
  ["application/vnd.wap.wmlc"] = "wmlc",
  ["application/vnd.google-earth.kml+xml"] = "kml",
  ["application/vnd.google-earth.kmz"] = "kmz",
  ["application/x-7z-compressed"] = "7z",
  ["application/x-cocoa"] = "cco",
  ["application/x-java-archive-diff"] = "jardiff",
  ["application/x-java-jnlp-file"] = "jnlp",
  ["application/x-makeself"] = "run",
  ["application/x-perl"] = "pl",
  ["application/x-pilot"] = "prc",
  ["application/x-rar-compressed"] = "rar",
  ["application/x-redhat-package-manager"] = "rpm",
  ["application/x-sea"] = "sea",
  ["application/x-shockwave-flash"] = "swf",
  ["application/x-stuffit"] = "sit",
  ["application/x-tcl"] = "tcl",
  ["application/x-x509-ca-cert"] = "crt",
  ["application/x-xpinstall"] = "xpi",
  ["application/xhtml+xml"] = "xhtml",
  ["application/zip"] = "zip",
  ["application/octet-stream"] = "bin",
  ["audio/midi"] = "mid",
  ["audio/mpeg"] = "mp3",
  ["audio/ogg"] = "ogg",
  ["audio/x-m4a"] = "m4a",
  ["audio/x-realaudio"] = "ra",
  ["video/3gpp"] = "3gpp",
  ["video/mp4"] = "mp4",
  ["video/mpeg"] = "mpeg",
  ["video/quicktime"] = "mov",
  ["video/webm"] = "webm",
  ["video/x-flv"] = "flv",
  ["video/x-m4v"] = "m4v",
  ["video/x-mng"] = "mng",
  ["video/x-ms-asf"] = "asf",
  ["video/x-ms-wmv"] = "wmv",
  ["video/x-msvideo"] = "avi"
}

-- Returns the common file extension from a content-type
function mimetype.get_mime_extension(content_type)
  return types[content_type]
end

-- Returns the mimetype and subtype
function mimetype.get_content_type(extension)
  for k,v in pairs(types) do
    if v == extension then
      return k
    end
  end
end

-- Returns the mimetype without the subtype
function mimetype.get_content_type_no_sub(extension)
  for k,v in pairs(types) do
    if v == extension then
      -- Before /
      return k:match('([%w-]+)/')
    end
  end
end

return mimetype
end