#!/usr/bin/env ruby

require_relative 'lib/intcode'

initial_memory = File.open('inputs/day25.txt') do |f|
  f.read.strip.split(',').map(&:to_i)
end
computer = Intcode.new(initial_memory)

loop do
  outputs = []
  computer.run_program { |n| outputs << n.chr }
  puts outputs.join
  exit 0 if computer.is_halted

  gets.split('').each { |c| computer.add_input(c.ord) }
end

# Largely a brute-force solution, manually exploring through the ship, picking
# things up, and starting over when the robot melted or got stuck in an
# electromagnet or whirling in an infinite loop.

