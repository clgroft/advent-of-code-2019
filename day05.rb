require_relative 'lib/intcode'

input = ARGV.shift.to_i
initial_memory = gets.split(",").map(&:to_i)

computer = Intcode.new(initial_memory)
computer.add_input(input)

computer.run_program { |n| puts "Output: #{n}" }

