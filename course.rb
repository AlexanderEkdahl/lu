require 'rubygems'
require 'bundler/setup'
require 'nokogiri'
require 'open-uri/cached'
require 'csv'
require 'debugger'

class Array
  def safe_join
    self.map { |x| x.gsub(';', ',') }.join(';') if self.length > 0
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
    # Split ' eller '? - only if multiple books were found
    @doc.xpath("//h2[contains(.,'Kurslitteratur')]/following::ul/li/text()").map(&:text)
  end

  def code
    @doc.xpath("//h2[1]/text()").text.split(',').first
  end

  def program
    (obligatory + optional).map do |x|
      x.strip.gsub(/-.*/, '')
    end.uniq.safe_join
  end

  def obligatory
    @doc.xpath("//span[@class='bold' and contains(.,'Obligatorisk')]/following::node()[1]").text.split(',')
  end

  def optional
    @doc.xpath("//span[@class='bold' and contains(.,'Valfri')]/following::node()[1]").text.split(',')
  end
end

if __FILE__ == $0
  courses = Nokogiri::HTML(open("http://kurser.lth.se/kursplaner/13_14/"))
  rows    = courses.css('.courselist table tr')

  CSV.open("courses.csv", "wb") do |csv|
    rows.each do |row|
      _, link, _, _ = row.css('td')
      course = Course.new("http://kurser.lth.se#{link.child[:href]}")
      csv << [course.code, course.name, course.program]
    end
  end
end
