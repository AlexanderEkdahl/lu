require 'test/unit'
require './parse2'

class TestExamples < Test::Unit::TestCase
  def test_isbn
    assert_item_isbn('9789144197524', 'Sparr, G: Linjär algebra. Studentlitteratur, 1997, ISBN: 9789144197524.')
    assert_item_isbn('9789144048789', 'Övningar i Linjär algebra. Studentlitteratur, 2007, ISBN: 978-91-44-04878-9.')
  end

  def test_extract_title_and_authors
    assert_item_extract_title_and_authors(['Datorsystem: program- och maskinvara', 'Brorsson M'],
                                          'Brorsson M: Datorsystem: program- och maskinvara, Studentlitteratur, 1999')
    assert_item_extract_title_and_authors(['Computer Organization and Design', 'Patterson, Hennessey'],
                                          'Patterson, Hennessey: Computer Organization and Design, 2 nd edition, Morgan Kaufman 1998.')
    assert_item_extract_title_and_authors(['Agile Software Development - Principles', 'Martin, R C'],
                                          'Martin, R C: Agile Software Development - Principles, Patterns, and Practices. Prentice Hall 2011.')
    assert_item_extract_title_and_authors(nil,
                                          'Laborationshandledning samt kopior på OH-bilder använda på föreläsningarna.')
    assert_item_extract_title_and_authors(['Linjär algebra', 'Sparr, G'],
                                          'Sparr, G: Linjär algebra. Studentlitteratur, 1997, ISBN: 9789144197524.')
    assert_item_extract_title_and_authors(['Geografisk informationsbehandling – teori', 'Harrie, L. (red.)'],
                                          'Harrie, L. (red.): Geografisk informationsbehandling – teori, metoder och tillämpningar, 6 upplagan. Studentlitteratur, 2013.')
  end

  def test_lookup
    item = Item.new('Sparr, G: Linjär algebra. Studentlitteratur, 1997, ISBN: 9789144197524.')
    assert_equal("has isbn", item.lookup)

    item = Item.new('Kurslitteraturen varierar i förhållande till årets valda tema.')
    assert_equal(false, item.lookup)
  end

  def method_missing(name, *args)
    if name.to_s =~ /^assert_item_(.+)$/
      run_assert_item_method($1, *args)
    else
      super
    end
  end

  def run_assert_item_method(assert, result, input)
    item = Item.new(input)
    assert_equal(result, item.send(assert))
  end
end
