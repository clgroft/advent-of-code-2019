require_relative 'lib/intcode'


def intcode_with_input(initial_memory, input)
  intcode = Intcode.new(initial_memory)
  intcode.add_input(input)
  intcode
end

def amplifiers(initial_memory, phases)
  phases.map { |phase| intcode_with_input(initial_memory, phase) }
end

def all_amplifier_chains(initial_memory, phase_range)
  phase_range.to_a
    .permutation
    .map { |phases| amplifiers(initial_memory, phases) }
end

def apply_amplifier(amp, input)
  return nil unless input
  output = nil
  amp.add_input(input)
  amp.run_program { |out| output = out }
  output
end

def apply_all_amplifiers(amplifiers, input)
  amplifiers.inject(input) { |input, amp| apply_amplifier(amp, input) }
end

def iterate_all_amplifiers(amplifiers, input)
  Enumerator.new do |y|
    signal = input
    loop do
      y << signal
      signal = apply_all_amplifiers(amplifiers, signal)
    end
  end
    .take_while { |signal| signal }
    .last
end


initial_memory = gets.split(",").map(&:to_i)

max_signal = all_amplifier_chains(initial_memory, 0..4)
  .map { |amplifiers| apply_all_amplifiers(amplifiers, 0) }
  .max

puts "Max thruster signal (no feedback): #{max_signal}"

max_feedback_signal = all_amplifier_chains(initial_memory, 5..9)
  .map do |amplifiers|
    most_recent_signal = 0

    loop do
      new_signal = apply_all_amplifiers(amplifiers, most_recent_signal)
      break unless new_signal
      most_recent_signal = new_signal
    end

    most_recent_signal
  end
  .max

puts "Max thruster signal (with feedback): #{max_feedback_signal}"
