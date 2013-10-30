# TODO Parse ISSN too(They should have isbn numbers as well)
# TODO Use another service when google books api fails
#  - http://docs.aws.amazon.com/AWSECommerceService/latest/DG/ItemLookup.html
# TODO Parse program/year
# TODO parse lu http://www.lu.se/lubas/courses
# CSV structure - ISBN13, Title, Authors, Courses

# convert isbn 10 to 13 beforehand?

require 'rubygems'
require 'bundler/setup'
require 'nokogiri'
require 'open-uri/cached'
require 'json'
require 'csv'
require 'debugger'

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
  Array(book['volumeInfo']['authors'])
end

def find_title(book)
  book['volumeInfo']['title']
end

def find_thumbnail(book)
  a = book['volumeInfo']['imageLinks']
  a['thumbnail'] if a != nil
end

def google_books_api(isbn)
  books = JSON.parse(open("https://www.googleapis.com/books/v1/volumes?q=isbn:#{isbn}&key=AIzaSyDdnBhErY3yMQ2UB6OBz6AIRlp6vrTlYsM").read)
  puts "Downloading https://www.googleapis.com/books/v1/volumes?q=isbn:#{isbn}"
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
    puts "Downloading http://kurser.lth.se#{link.child[:href]}"
    isbns = scan(page)

    isbns.each do |isbn|
      if name.text == ""
        books_and_codes[isbn] << code.text
      else
        books_and_codes[isbn] << "#{code.text} - #{name.text}"
      end
    end
  end

  books_and_codes.each do |key, value|
    book = google_books_api(key)

    if book and (id = find_isbn13(book))
      if id
        # If book was referenced differently(using isbn 10 or 13) the data won't get properly merged
        if books.key?(id)
          books[id][2] << ";#{value}"
        else
          books[id] = [find_title(book), find_authors(book).join(';'), value.join(';'), find_thumbnail(book)]
        end
      end
    end
  end

  CSV.open("lth.csv", "wb") do |csv|
    books.each do |key, values|
      csv << [key, *values]
    end
  end
end
