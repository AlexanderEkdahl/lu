require 'rubygems'
require 'bundler/setup'
require 'nokogiri'
require 'open-uri/cached'
require 'debugger'
require 'json'

URL  = 'http://www.lu.se/lubas/courses?title=any'
ROWS = '.main-aside-wrapper > div > .page-main > div > .pane-views-results > .pane-content > div a'

json = {}
page = Nokogiri::HTML(open(URL))

page.css(ROWS).each do |row|
  name = row.text
  code = URI.unescape(row[:href].gsub('/lubas/i-uoh-lu-', ''))

  json[code] = name
end

File.open('lubas.json', 'w') do |file|
  file.write(JSON.pretty_generate(json))
end
