require 'rubygems'
require 'bundler/setup'
require 'nokogiri'
require 'open-uri/cached'
require 'debugger'
require 'json'

class Course
  PROGRAMS = %w{A B BI BME C D E F I K L M MD N Pi V W}

  def initialize(url)
    @doc = Nokogiri::HTML(open(url))
  end

  def name
    @doc.xpath("//h1[1]/node()").first.text
  end

  def literature
    @doc.xpath("//h2[contains(.,'Kurslitteratur')]/following::ul/li/text()").map(&:text)
  end

  def code
    @doc.xpath("//h2[1]/text()").text.split(',').first
  end

  def program
    (obligatory + optional).map do |x|
      x.scan(%r{\b(?:#{PROGRAMS.join('|')})\d}).first
    end.compact.uniq
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
  json    = {}
  rows    = courses.css('.courselist table tr')

  rows.each do |row|
    course = Course.new("http://kurser.lth.se#{row.css('td')[1].child[:href]}")
    json[course.code] = {
      name:       course.name,
      program:    course.program,
      literature: course.literature
    }
  end

  File.open('courses.json', 'w') do |file|
    file.write(JSON.pretty_generate(json))
  end
end
