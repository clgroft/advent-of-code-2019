#!/usr/bin/env ruby

require_relative 'lib/intcode'

EMPTY = 0
WALL = 1
BLOCK = 2
PADDLE = 3
BALL = 4

initial_memory = ARGF.gets.split(",").map(&:to_i)
initial_memory[0] = 2 # free play!

computer = Intcode.new(initial_memory)
screen = Hash.new(0)
score = nil

until computer.is_halted
  output = []
  computer.run_program { |n| output << n }
  output.each_slice(3) do |x, y, id|
    if x == -1 && y == 0
      score = id
    else
      screen[[x,y]] = id
    end
  end

  ball_position = screen.select { |p, id| id == BALL }.first[0][0]
  paddle_position = screen.select { |p, id| id == PADDLE }.first[0][0]
  direction = ball_position <=> paddle_position
  computer.add_input(direction)
end

puts "Final score: #{score}"
puts "All blocks destroyed: #{screen.values.count { |id| id == BLOCK } == 0}"

