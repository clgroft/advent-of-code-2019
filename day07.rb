require_relative 'lib/intcode'

initial_memory = gets.split(",").map(&:to_i)

max_signal = (0..4).to_a.permutation.map do |perm|
  perm.map do |phase|
    amp = Intcode.new(initial_memory)
    amp.add_input(phase)
    amp
  end.inject(0) do |input, amp|
    amp.add_input(input)
    output = nil
    amp.run_program { |out| output = out }
    output
  end
end.max

puts "Max thruster signal: #{max_signal}"

