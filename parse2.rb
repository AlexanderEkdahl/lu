# Has to support different types of identifiers. ISBN OCLC w/e
# LIST EVERY studentlitteratr/prentice hall utgivare och ta bort det först

require 'rubygems'
require 'bundler/setup'
require 'nokogiri'
require 'open-uri/cached'
require 'csv'
require 'lisbn'
require 'debugger'

class API
  def find_by_isbn(isbn)
    google_api(query)
  end

  def find_by_author_and_title

  end

  def google_api(query)

  end
end

class Item
  def initialize(literature)
    @literature = literature
  end

  def lookup
    if q = isbn
      # find_by_isbn(q)
      "has isbn"
    else
      false
    end
  end

  def extract_title_and_authors
    _, authors, title, _ = @literature.match(/([^:]+):\s?([^,.]+)/).to_a
    [title, authors] unless authors.nil? or title.nil?
  end

  def isbn
    # should loop through all scan results
    scan = @literature.scan(/ISBN:?(?:\s?1[30])?:?\s?([0-9][0-9Xx -]*)/).flatten.first
    if scan
      isbn = Lisbn.new(scan)
      if isbn != "" and isbn.valid?
        return isbn.isbn13
      end
    end
  end

  def name
    [title, subtitle]
  end
end

class Course
  def initialize(url)
    @doc = Nokogiri::HTML(open(url))
  end

  def name
    @doc.xpath("//h1[1]/node()").first.text
  end

  def literature
    # Split ' eller '?
    @doc.xpath("//h2[contains(.,'Kurslitteratur')]/following::ul/li/text()").map(&:text)
  end

  def code
    @doc.xpath("//h2[1]/text()").text.split(',').first
  end

  def program
    (obligatory + optional).map(&:strip).uniq
  end

  def obligatory
    @doc.xpath("//span[@class='bold' and contains(.,'Obligatorisk')]/following::node()[1]").text.split(',')
  end

  def optional
    @doc.xpath("//span[@class='bold' and contains(.,'Valfri')]/following::node()[1]").text.split(',')
  end
end

if __FILE__ == $0
  courses = Nokogiri::HTML(open("http://kurser.lth.se/kursplaner/12_13/"))
  rows    = courses.css('.courselist table tr')

  CSV.open("courses.csv", "wb") do |csv|
    rows.each do |row|
      _, link, _, _ = row.css('td')
      course = Course.new("http://kurser.lth.se#{link.child[:href]}")
      csv << [course.name, course.code, course.program, course.literature]
    end
  end
end
