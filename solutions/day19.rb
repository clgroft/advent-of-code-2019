#!/usr/bin/env ruby

require_relative 'lib/intcode'


class SleighFinder
  def initialize(initial_memory)
    @initial_memory = initial_memory
  end

  def closest_point
    x, y = 0, 0
    loop do
      (y += 1 and next) unless is_affected?(x+99, y)
      (x += 1 and next) unless is_affected?(x, y+99)
      return [x,y]
    end
  end

  def is_affected?(x, y)
    computer = Intcode.new(@initial_memory)
    computer.add_input(x)
    computer.add_input(y)
    output = nil
    computer.run_program { |n| output = n }
    output == 1
  end
end


initial_memory = gets.split(",").map(&:to_i)
finder = SleighFinder.new(initial_memory)

num_points_affected =
  (0...50).map do |x|
    (0...50).count { |y| finder.is_affected?(x, y) }
  end.inject(:+)
puts "Number of points affected: #{num_points_affected}"

closest_point = finder.closest_point
puts "Closest point is #{closest_point}"

