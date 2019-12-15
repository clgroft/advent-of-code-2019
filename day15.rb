#!/usr/bin/env ruby

require_relative 'lib/intcode'

NORTH = 1
SOUTH = 2
WEST = 3
EAST = 4

WALL = 0
EMPTY_SPACE = 1
FOUND_SYSTEM = 2

def new_coordinates(start_coordinates, direction)
  x, y = start_coordinates
  case direction
  when NORTH
    [x, y-1]
  when SOUTH
    [x, y+1]
  when WEST
    [x-1, y]
  when EAST
    [x+1, y]
  end
end

initial_memory = gets.split(",").map(&:to_i)
starting_computer = Intcode.new(initial_memory)

num_steps = {[0,0] => 0} # zero steps from the origin to the origin
queue = [[[0,0], starting_computer]]

until queue.empty?
  start_coordinates, intcode_state = queue.shift
  (NORTH..EAST).each do |dir|
    finish_coordinates = new_coordinates(start_coordinates, dir)
    next if num_steps.has_key?(finish_coordinates)
    new_intcode_state = intcode_state.dup
    new_intcode_state.add_input(dir)
    new_intcode_state.run_program do |status|
      case status
      when WALL
        num_steps[finish_coordinates] = :wall
      when EMPTY_SPACE
        num_steps[finish_coordinates] = num_steps[start_coordinates] + 1
        queue << [finish_coordinates, new_intcode_state]
      when FOUND_SYSTEM
        puts "Found oxygen system in #{num_steps[start_coordinates] + 1} steps"
        exit 0
      end
    end
  end
end

puts "Ran out of places to go but couldn't find oxygen system!"
exit 1

# computer.run_program { |n| puts "Output: #{n}" }

