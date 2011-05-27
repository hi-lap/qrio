module Qrio
  class SamplingGrid
    attr_reader :origin_corner, :orientation, :bounds, :angles

    def initialize(matrix, finder_patterns)
      @matrix          = matrix
      @finder_patterns = finder_patterns
      @angles          = []

      find_origin_corner
      detect_orientation
    end

    def find_origin_corner
      build_finder_pattern_neighbors

      shared_corners = @finder_patterns.select do |fp|
        fp.neighbors.select(&:right_angle?).count > 1
      end

      # TODO : handle multiple possible matches
      if @origin_corner = shared_corners.first
        set_bounds
      end
    end

    def set_bounds
      @bounds = @origin_corner.dup
      @bounds.neighbors.select(&:right_angle?).each do |n|
        @bounds = @bounds.union(n.destination)
      end
    end

    # which way is the QR rotated?
    #   0) normal - shared finder patterns in top left
    #   1)        - shared finder patterns in top right
    #   2)        - shared finder patterns in bottom right
    #   3)        - shared finder patterns in bottom left
    def detect_orientation
      # TODO : handle multiple possible matches
      other_corners = @origin_corner.neighbors.select(&:right_angle?)[0,2]

      dc = other_corners.map(&:distance).inject(0){|s,d| s + d } / 2.0
      threshold = dc / 2.0

      other_corners = other_corners.map(&:destination)
      xs = other_corners.map{|fp| fp.center.first }
      ys = other_corners.map{|fp| fp.center.last }

      above = ys.select{|y| y < (@origin_corner.center.last - threshold) }
      left  = xs.select{|x| x < (@origin_corner.center.first - threshold) }

      @orientation = if above.any?
        left.any? ? 2 : 3
      else
        left.any? ? 1 : 0
      end
    end

    def build_finder_pattern_neighbors
      @finder_patterns.each do |source|
        @finder_patterns.each do |destination|
          next if source.center == destination.center
          @angles << Neighbor.new(source, destination)
        end
      end
    end
  end
end
