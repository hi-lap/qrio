require_relative '../lib/qrio'
require 'test/unit'

class TestSamplingGrid < Test::Unit::TestCase
  def setup
    @matrix = Qrio::BoolMatrix.new(Array.new(441, false), 21, 21)
  end

  def test_orientation_detection
    finder_patterns = build_finder_patterns([
      [ 0, 0, 7, 7],
      [14, 0,20, 7],
      [ 0,14,14,20]
    ])

    grid = Qrio::SamplingGrid.new(@matrix, finder_patterns)
    assert_equal "F[0,0,7,7]", grid.origin_corner.to_s
    assert_equal 0, grid.orientation

    finder_patterns = build_finder_patterns([
      [ 0, 0, 7, 7],
      [14, 0,20, 7],
      [14,14,20,20]
    ])

    grid = Qrio::SamplingGrid.new(@matrix, finder_patterns)
    assert_equal "F[14,0,20,7]", grid.origin_corner.to_s
    assert_equal 1, grid.orientation

    finder_patterns = build_finder_patterns([
      [14, 0,20, 7],
      [14,14,20,20],
      [ 0,14,14,20]
    ])

    grid = Qrio::SamplingGrid.new(@matrix, finder_patterns)
    assert_equal "F[14,14,20,20]", grid.origin_corner.to_s
    assert_equal 2, grid.orientation

    finder_patterns = build_finder_patterns([
      [14,14,20,20],
      [ 0,14,14,20],
      [ 0, 0, 7, 7],
    ])

    grid = Qrio::SamplingGrid.new(@matrix, finder_patterns)
    assert_equal "F[0,14,14,20]", grid.origin_corner.to_s
    assert_equal 3, grid.orientation

    #assert_equal '7.21', ('%.2f' % fp.pixel_width)
  end

  private

  def build_finder_patterns(arrays)
    arrays.map do |coordinates|
      Qrio::FinderPatternSlice.new(*coordinates)
    end
  end
end

__END__

      [105,217,155,266],
      [290,216,341,266],
      [100,401,151,452]

