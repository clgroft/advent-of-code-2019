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

puts "Max thruster signal (no feedback): #{max_signal}"

max_feedback_signal = (5..9).to_a.permutation.map do |perm|
  amplifiers = perm.map do |phase|
    amp = Intcode.new(initial_memory)
    amp.add_input(phase)
    amp
  end

  most_recent_signal = 0

  loop do
    new_signal = amplifiers.inject(most_recent_signal) do |input, amp|
      if input
        amp.add_input(input)
        output = nil
        amp.run_program { |out| output = out }
        output
      else
        nil
      end
    end
    break unless new_signal
    most_recent_signal = new_signal
  end
  most_recent_signal
end.max

puts "Max thruster signal (with feedback): #{max_feedback_signal}"
