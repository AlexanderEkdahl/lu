require 'test/unit'
require './parse'

class TestExamples < Test::Unit::TestCase
  def test_scan
    assert_scan("0867589094", "ISBN 0-86758-909-4")
    assert_scan("9789144066257", "ISBN: 978-91-44-06625-7")
    assert_scan("9780415419468", "ISBN: 9780415419468")
    assert_scan("9780415419468", "ISBN 13: 9780415419468")
    assert_scan("012375030", "ISBN: 10: 012375030")
    assert_scan("9780123750303", "ISBN: 13: 9780123750303")
    assert_scan("047124824X", "ISBN 0-471-24824-X")
  end

  def assert_scan(result, page)
    assert_equal([result], scan(page))
  end
end
