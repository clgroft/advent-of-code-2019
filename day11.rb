#!/usr/bin/env ruby

require_relative 'lib/intcode'


def turn_counterclockwise(dir)
  (dir + 1) % 4
end

def turn_clockwise(dir)
  (dir + 3) % 4
end


class HullPaintingRobot

  BLACK = 0
  WHITE = 1

  UP = 0
  LEFT = 1
  DOWN = 2
  RIGHT = 3

  COUNTERCLOCKWISE = 0
  CLOCKWISE = 1

  def initialize(program)
    @intcode = Intcode.new(program)
    @cells = {}
    @x, @y = 0, 0
  end

  def start_on_white
    @cells[[0,0]] = WHITE
  end

  def paint_hull
    direction = UP

    loop do
      @intcode.add_input(get_color)
      outputs = []
      @intcode.run_program { |out| outputs << out }
      case outputs.length
      when 0
        return
      when 2
        color, rotate = outputs
        set_color(color)
        direction = new_direction(direction, rotate)
        new_xy(direction)
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
        @cells[[x,y]] == WHITE ? "*" : " "
      end.join + "\n"
    end.join
  end

  def get_color
    @cells[[@x, @y]] || BLACK
  end

  def set_color(color)
    @cells[[@x, @y]] = color
  end

  def new_direction(direction, rotate)
    case rotate
    when COUNTERCLOCKWISE
      turn_counterclockwise(direction)
    when CLOCKWISE
      turn_clockwise(direction)
    else
      puts "Illegal rotate direction #{rotate}"
      exit 1
    end
  end

  def new_xy(direction)
    case direction
    when UP
      @y -= 1
    when LEFT
      @x -= 1
    when DOWN
      @y += 1
    when RIGHT
      @x += 1
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

