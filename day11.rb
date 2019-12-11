#!/usr/bin/env ruby

require_relative 'lib/intcode'


class Color
  BLACK = 0
  WHITE = 1
end

class Direction
  UP = 0
  LEFT = 1
  DOWN = 2
  RIGHT = 3
end

class RotateDirection
  COUNTERCLOCKWISE = 0
  CLOCKWISE = 1
end

def turn_counterclockwise(dir)
  (dir + 1) % 4
end

def turn_clockwise(dir)
  (dir + 3) % 4
end


class HullPaintingRobot

  def initialize(program)
    @intcode = Intcode.new(program)
    @cells = {}
  end

  def start_on_white
    @cells[[0,0]] = Color::WHITE
  end

  def paint_hull
    x, y = 0, 0
    direction = Direction::UP

    loop do
      @intcode.add_input(get_color(x, y))
      outputs = []
      @intcode.run_program { |out| outputs << out }
      case outputs.length
      when 0
        return
      when 2
        color, rotate = outputs
        set_color(x, y, color)
        direction = new_direction(direction, rotate)
        x, y = new_xy(x, y, direction)
      else
        puts "Output #{outputs} should have length 0 or 2"
        exit 1
      end
    end
  end

  def number_cells_painted
    @cells.size
  end

  def print_picture
    x_min, x_max = @cells.keys.map { |x, _y| x }.minmax
    y_min, y_max = @cells.keys.map { |_x, y| y }.minmax

    (y_min..y_max).map do |y|
      (x_min..x_max).map do |x|
        @cells[[x,y]] == Color::WHITE ? "*" : " "
      end.join + "\n"
    end.join
  end

  def get_color(x, y)
    @cells[[x,y]] || Color::BLACK
  end

  def set_color(x, y, color)
    @cells[[x,y]] = color
  end

  def new_direction(direction, rotate)
    case rotate
    when RotateDirection::COUNTERCLOCKWISE
      turn_counterclockwise(direction)
    when RotateDirection::CLOCKWISE
      turn_clockwise(direction)
    else
      puts "Illegal rotate direction #{rotate}"
      exit 1
    end
  end

  def new_xy(x, y, direction)
    case direction
    when Direction::UP
      [x, y-1]
    when Direction::LEFT
      [x-1, y]
    when Direction::DOWN
      [x, y+1]
    when Direction::RIGHT
      [x+1, y]
    else
      puts "Illegal direction #{direction}"
      exit 1
    end
  end
end

program = ARGF.read.strip.split(',').map(&:to_i)
robot = HullPaintingRobot.new(program)
robot.paint_hull
puts "Number of cells painted: #{robot.number_cells_painted}"
puts

robot = HullPaintingRobot.new(program)
robot.start_on_white
robot.paint_hull
puts robot.print_picture

