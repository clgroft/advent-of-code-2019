def run_program(initial_memory, noun, verb)
  memory = initial_memory.dup
  memory[1] = noun
  memory[2] = verb

  pc = 0
  loop do
    case memory[pc]
    when 1
      memory[memory[pc+3]] = memory[memory[pc+1]] + memory[memory[pc+2]]
    when 2
      memory[memory[pc+3]] = memory[memory[pc+1]] * memory[memory[pc+2]]
    when 99
      return memory[0]
    else
      puts "Error: memory[pc] = #{memory[pc]} is not a valid opcode"
      exit 1
    end
    pc += 4
  end
end

def check_input(initial_memory, noun, verb)
  result = run_program(initial_memory, noun, verb)
  puts "noun = #{noun}, verb = #{verb}" and exit 0 if result == 19690720
end

initial_memory = gets.split(",").map(&:to_i)

(0...initial_memory.size).each do |n|
  (0..n).each do |noun|
    verb = n
    check_input(initial_memory, noun, verb)
  end

  (0...n).each do |verb|
    noun = n
    check_input(initial_memory, noun, verb)
  end
end
