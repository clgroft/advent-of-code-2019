#!/usr/bin/env ruby

require_relative 'lib/intcode'


initial_memory = gets.split(",").map(&:to_i)
computer = Intcode.new(initial_memory)

# print prompt
prompt = []
computer.run_program { |n| prompt << n.chr }
part2_computer = computer.dup  # don't have to print prompt again

# load and run springcode program
springcode = [
  "NOT J T", # T = true
  "AND A T",
  "AND B T",
  "AND C T", # T = A & B & C
  "NOT T J", # J = ~(A & B & C)
  "AND D J", # J = ~(A & B & C) & D
  "WALK",
].map { |l| l + "\n" }.join
springcode.chars.each { |c| computer.add_input(c.ord) }
output_codes = []
computer.run_program { |n| output_codes << n }

# did it work?
if output_codes.last > 255
  puts "Success!  Hull damage: #{output_codes.last}"
else
  puts "Failed; map below:"
  puts output_codes.map(&:chr).join
  exit 1
end

springcode = [
  "NOT T J", # T = false, J = true
  "AND A J",
  "AND B J",
  "AND C J", # J = A & B & C
  "NOT J T", # T = ~(A & B & C)
  "AND T J", # J = false
  "OR E J",
  "OR H J",
  "AND D J",
  "AND T J",
  "RUN",
].map { |l| l + "\n" }.join
springcode.chars.each { |c| part2_computer.add_input(c.ord) }
output_codes = []
part2_computer.run_program { |n| output_codes << n }

if output_codes.last > 255
  puts "Success!  Total hull damage: #{output_codes.last}"
else
  puts "Failed; output below:"
  puts output_codes.map(&:chr).join
  exit 1
end

# # Part 1: find and add the intersection alignment parameters
# camera_feed = []
# computer.run_program { |n| camera_feed << n.chr }
# picture = camera_feed.join
# # puts picture
#
# picture_array = picture.split("\n").map { |l| l.split('') }
# num_rows = picture_array.length
# num_columns = picture_array[0].length
# alignment_params_sum =
#   (1..(num_rows - 2)).map do |y|
#     y * (1..(num_columns - 2)).select do |x|
#       picture_array[y][x] == '#' &&
#         picture_array[y][x-1] == '#' &&
#         picture_array[y][x+1] == '#' &&
#         picture_array[y-1][x] == '#' &&
#         picture_array[y+1][x] == '#'
#     end.inject(0, :+)
#   end.inject(0, :+)
# puts "Sum of alignment parameters: #{alignment_params_sum}"
# puts
#
# # Part 2: find a path through the scaffolding, compress it
# # into three subroutines (I did this by hand, *no* shame),
# # and have the "vacuum robot" execute the result
#
# procedure_A = "R,6,L,6,L,10"
# procedure_B = "L,8,L,6,L,10,L,6"
# procedure_C = "R,6,L,8,L,10,R,6"
# main_procedure = "A,B,A,B,C,A,B,C,A,C"
# options = "n"
# inputs = [
#   main_procedure,
#   procedure_A,
#   procedure_B,
#   procedure_C,
#   options
# ].map { |str| str + "\n" }
#
# initial_memory[0] = 2
# computer = Intcode.new(initial_memory)
#
# puts "Starting image:"
# puts
# inputs.each do |input|
#   out_chars = []
#   computer.run_program { |out| out_chars << out.chr }
#   puts out_chars.join + input
#   input.chars.each { |c| computer.add_input(c.ord) }
# end
#
# puts
# puts "Image when done:"
# outputs = []
# computer.run_program { |out| outputs << out }
# puts outputs[0...outputs.size-1].map(&:chr).join
# puts "Units of dust collected: #{outputs[-1]}"
#
