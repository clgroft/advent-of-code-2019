class Intcode
  def initialize(initial_memory)
    @memory = initial_memory.dup
    @input = []
  end

  def get_register(register)
    @memory[register]
  end

  def set_register(register, value)
    @memory[register] = value
  end

  def add_input(new_input)
    @input.push(new_input)
  end

  def take_input
    @input.shift
  end

  def run_program
    @pc = 0
    loop do
      opcode = get_register(@pc)
      case opcode
      when 99
        return

      when 1
        set_register(
          get_register(@pc + 3),
          get_register(get_register(@pc + 1)) + get_register(get_register(@pc + 2)))
        @pc += 4

      when 2
        set_register(
          get_register(@pc + 3),
          get_register(get_register(@pc + 1)) * get_register(get_register(@pc + 2)))
        @pc += 4

      when 3
        input = take_input
        puts "Error: no input available" and exit 1 unless input
        set_register(get_register(@pc + 1), input)
        @pc += 2

      when 4
        yield get_register(@pc + 1)
        @pc += 2

      else
        puts "Error: #{opcode} is not a valid opcode"
        exit 1

      end
    end
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
