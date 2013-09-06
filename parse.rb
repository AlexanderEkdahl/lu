# TODO Parse ISSN too(They should have isbn numbers as well)
# TODO Use another service when google books api fails
#  - http://docs.aws.amazon.com/AWSECommerceService/latest/DG/ItemLookup.html
# TODO Parse program/year
# TODO parse lu http://www.lu.se/lubas/courses


# CSV structure - ISBN13, Title, Authors, Courses

require 'nokogiri'
require 'open-uri/cached'
require 'debugger'
require 'json'
require 'csv'

def strip_isbn(isbn)
  isbn.gsub(/[- ]/, '')
end

def scan(page)
  page.scan(/ISBN:?(?:\s?1[30])?:?\s?([0-9][0-9Xx -]*)/).flatten.map { |isbn| strip_isbn(isbn) }
end

def find_isbn13(book)
  return nil unless book['volumeInfo']['industryIdentifiers']

  book['volumeInfo']['industryIdentifiers'].each do |id|
    return id['identifier'] if id['type'] == 'ISBN_13'
  end
  nil
end

def find_authors(book)
  book['volumeInfo']['authors']
end

def find_title(book)
  book['volumeInfo']['title']
end

def google_books_api(isbn)
  books = JSON.parse(open("https://www.googleapis.com/books/v1/volumes?q=isbn:#{isbn}&key=AIzaSyDdnBhErY3yMQ2UB6OBz6AIRlp6vrTlYsM").read)
  books['items'] ? books['items'].first : nil
end

if __FILE__ == $0
  courses = Nokogiri::HTML(open("http://kurser.lth.se/kursplaner/12_13/"))
  table   = courses.css('.courselist table')
  rows    = table.css('tr')
  books_and_codes = Hash.new { |hash, key| hash[key] = [] }
  books   = {}

  rows.each do |row|
    code, link, _, name = row.css('td')
    page  = open("http://kurser.lth.se#{link.child[:href]}").read
    isbns = scan(page)

    isbns.each do |isbn|
      books_and_codes[isbn] << "#{code.text} - #{name.text}"
    end
  end

  books_and_codes.each do |key, value|
    book = google_books_api(key)

    if book and (id = find_isbn13(book))
      if id
        books[id] = [find_title(book), find_authors(book), value]
      end
    end
  end

  CSV.open("lth.csv", "wb") do |csv|
    books.each do |key, values|
      csv << [key, *values]
    end
  end
end
