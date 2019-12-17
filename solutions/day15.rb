#!/usr/bin/env ruby

require_relative 'lib/intcode'


NORTH = 1
SOUTH = 2
WEST = 3
EAST = 4

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


WALL = 0
EMPTY_SPACE = 1
FOUND_SYSTEM = 2

def find_oxygen_system(starting_computer)
  num_steps = {[0,0] => 0} # zero steps from the origin to the origin
  queue = [[[0,0], starting_computer]]
  system_position = nil
  system_steps = nil

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
          system_position = finish_coordinates
          system_steps = num_steps[start_coordinates] + 1
          num_steps[finish_coordinates] = system_steps
          queue << [finish_coordinates, new_intcode_state]
        end
      end
    end
  end

  [system_position, system_steps, num_steps]
end

def picture_of_region_map(region_map, oxygen_system_coordinates)
  x_min, x_max = region_map.keys.map { |x, _y| x }.minmax
  y_min, y_max = region_map.keys.map { |_x, y| y }.minmax
  (y_min..y_max).map do |y|
    (x_min..x_max).map do |x|
      character(region_map, x, y, oxygen_system_coordinates)
    end.join + "\n"
  end.join
end

def character(region_map, x, y, oxygen_system_coordinates)
  point = [x,y]
  contents = region_map[point]
  return '*' if contents.nil? || contents == :wall
  return '@' if point == oxygen_system_coordinates
  return '#' if point == [0,0]
  ' '
end

def size_of_region_map(region_map, system_coordinates)
  num_minutes = {system_coordinates => 0}
  queue = [system_coordinates]
  max_minutes = 0

  until queue.empty?
    start_coordinates = queue.shift
    next_minutes = num_minutes[start_coordinates] + 1
    (NORTH..EAST).each do |dir|
      finish_coordinates = new_coordinates(start_coordinates, dir)
      next if num_minutes.has_key?(finish_coordinates)
      next if region_map[finish_coordinates] == :wall
      num_minutes[finish_coordinates] = next_minutes
      max_minutes = next_minutes
      queue << finish_coordinates
    end
  end
  max_minutes
end


initial_memory = gets.split(",").map(&:to_i)
starting_computer = Intcode.new(initial_memory)

oxygen_system_coordinates, num_steps, region_map = find_oxygen_system(starting_computer)
puts "Found oxygen system in #{num_steps} steps at #{oxygen_system_coordinates}"
puts

puts picture_of_region_map(region_map, oxygen_system_coordinates)
puts

oxygen_fill_time = size_of_region_map(region_map, oxygen_system_coordinates)
puts "Oxygen will fill region in #{oxygen_fill_time} minutes"

