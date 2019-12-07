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

def apply_all_amplifiers(amplifiers, input=0)
  amplifiers.inject(input) { |input, amp| apply_amplifier(amp, input) }
end

def iterate_all_amplifiers(amplifiers)
  Enumerator.new do |y|
    signal = 0
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
  .map { |amplifiers| apply_all_amplifiers(amplifiers) }
  .max

puts "Max thruster signal (no feedback): #{max_signal}"

max_feedback_signal = all_amplifier_chains(initial_memory, 5..9)
  .map { |amplifiers| iterate_all_amplifiers(amplifiers) }
  .max

puts "Max thruster signal (with feedback): #{max_feedback_signal}"
