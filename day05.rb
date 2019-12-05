class Intcode
  def initialize(initial_memory)
    @memory = initial_memory.dup
  end

  def get_register(register)
    @memory[register]
  end

  def set_register(register, value)
    @memory[register] = value
  end

  def run_program
    pc = 0
    loop do
      opcode = get_register(pc)
      case opcode
      when 99
        return
      when 1
        set_register(
          get_register(pc + 3),
          get_register(get_register(pc + 1)) + get_register(get_register(pc + 2)))
        pc += 4
      when 2
        set_register(
          get_register(pc + 3),
          get_register(get_register(pc + 1)) * get_register(get_register(pc + 2)))
        pc += 4
      else
        puts "Error: #{opcode} is not a valid opcode"
      end
    end
  end
end

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
  computer = Intcode.new(initial_memory)
  computer.set_register(1, noun)
  computer.set_register(2, verb)
  computer.run_program
  result = computer.get_register(0)
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
