require 'test/unit'
require './parse'

class TestExamples < Test::Unit::TestCase
  def test_scan
    assert_scan('0867589094',    'ISBN 0-86758-909-4')
    assert_scan('9789144066257', 'ISBN: 978-91-44-06625-7')
    assert_scan('9780415419468', 'ISBN: 9780415419468')
    assert_scan('9780415419468', 'ISBN 13: 9780415419468')
    assert_scan('012375030',     'ISBN: 10: 012375030')
    assert_scan('9780123750303', 'ISBN: 13: 9780123750303')
    assert_scan('047124824X',    'ISBN 0-471-24824-X')
    assert_scan('9780465025787', 'ISBN: 13:9780465025787')
    assert_scan('0415357977',    'ISBN10: 0-415-35797-7')
    assert_equal([],        scan('ISBN: Diehl, S. Kapitel P,T, A.'))
  end

  def test_find_isbn13
    book = google_books_api('0471209066')
    assert_equal('9780471209065', find_isbn13(book))
    assert_equal(["Frank Ching"], find_authors(book))

    book = google_books_api('9789144066257')
    assert_equal('9789144066257', find_isbn13(book))
    assert_equal("Flervariabelanalys med Maple", find_title(book))
    assert_equal(["Gerd Brandell", "Anders Holst", "Sigrid Sjöstrand"], find_authors(book))
  end

  def assert_scan(result, page)
    assert_equal([result], scan(page))
  end
end
