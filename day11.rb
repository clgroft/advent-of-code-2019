#!/usr/bin/env ruby

require_relative 'lib/intcode'


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
    @cells = Hash.new(BLACK)
    @x, @y = 0, 0
    @direction = UP
  end

  def start_on_white
    @cells[[0,0]] = WHITE
  end

  def paint_hull
    loop do
      next_steps = get_next_steps
      case next_steps.length
      when 0
        return
      when 2
        process_next_steps(*next_steps)
      else
        puts "Next steps #{next_steps} should have length 0 or 2"
        exit 1
      end
    end
  end

  private

  def get_next_steps
    @intcode.add_input(current_color)
    outputs = []
    @intcode.run_program { |out| outputs << out }
    outputs
  end

  def process_next_steps(color, rotate_direction)
    paint(color)
    rotate(rotate_direction)
    advance
  end

  def current_color
    get_color(@x, @y)
  end

  def get_color(x, y)
    @cells[[x, y]]
  end

  def paint(color)
    @cells[[@x, @y]] = color
  end

  def rotate(rotate_direction)
    case rotate_direction
    when COUNTERCLOCKWISE
      @direction = (@direction + 1) % 4
    when CLOCKWISE
      @direction = (@direction + 3) % 4
    else
      puts "Illegal rotate direction #{rotate}"
      exit 1
    end
  end

  def advance
    case @direction
    when UP
      @y -= 1
    when LEFT
      @x -= 1
    when DOWN
      @y += 1
    when RIGHT
      @x += 1
    else
      puts "Illegal direction #{@direction}"
      exit 1
    end
  end

  public

  def number_cells_painted
    @cells.size
  end

  def print_picture
    x_min, x_max = @cells.keys.map { |x, _y| x }.minmax
    y_min, y_max = @cells.keys.map { |_x, y| y }.minmax
    (y_min..y_max).map { |y| row(y, x_min, x_max) }.join
  end

  private

  def row(y, x_min, x_max)
    (x_min..x_max).map { |x| get_color(x, y) == WHITE ? "*" : " " }.join + "\n"
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

