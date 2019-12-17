#!/usr/bin/env ruby

require_relative 'lib/intcode'

EMPTY = 0
WALL = 1
BLOCK = 2
PADDLE = 3
BALL = 4

initial_memory = ARGF.gets.split(",").map(&:to_i)

computer = Intcode.new(initial_memory)
output = []
computer.run_program { |n| output << n }

screen = Hash.new(0)
output.each_slice(3) { |x, y, id| screen[[x,y]] = id }

num_block_tiles = screen.values.count { |id| id == BLOCK }
puts "Number of block tiles: #{num_block_tiles}"

