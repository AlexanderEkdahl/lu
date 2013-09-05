# TODO Parse ISSN too(They should have isbn numbers as well)
# TODO Use another service when google books api fails
#  - http://docs.aws.amazon.com/AWSECommerceService/latest/DG/ItemLookup.html
# TODO Parse program/year

require 'nokogiri'
require 'open-uri/cached'
require 'debugger'
require 'json'
require 'csv'

def strip_isbn(isbn)
  isbn.gsub(/[- ]/, '')
end

def scan(page)
  page.scan(/ISBN:?(?: 1[30])?:?\s([0-9x -]*)/i).flatten.map { |isbn| strip_isbn(isbn) }
end

if __FILE__ == $0
  courses = Nokogiri::HTML(open("http://kurser.lth.se/kursplaner/12_13/"))
  table   = courses.css('.courselist table')
  rows    = table.css('tr')

  CSV.open("lth.csv", "wb") do |csv|
    rows.each do |row|
      code, link, _, name = row.css('td')
      page  = open("http://kurser.lth.se#{link.child[:href]}").read
      isbns = scan(page)

      isbns.each do |isbn|
        csv << [code.text, name.text, isbn]
      end
    end
  end
end
