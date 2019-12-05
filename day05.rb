module Opcodes
  HALT = 99

  ADD = 1
  MULT = 2

  READ = 3
  WRITE = 4

  JUMP_IF_TRUE = 5
  JUMP_IF_FALSE = 6

  LESS_THAN = 7
  EQUALS = 8
end

module ParameterModes
  POSITION = 0
  IMMEDIATE = 1
end

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

  def parameter_mode(offset)
    (get_register(@pc) / (10 ** (offset + 1))) % 10
  end

  def get_value(offset)
    contents = get_register(@pc + offset)

    case parameter_mode(offset)
    when ParameterModes::POSITION
      get_register(contents)

    when ParameterModes::IMMEDIATE
      contents

    else
      puts "Error: invalid mode at PC = #{@pc}, offset = #{offset}"
      exit 1
    end
  end

  def set_value(offset, value)
    set_register(get_register(@pc + offset), value)
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
      opcode = get_register(@pc) % 100
      case opcode
      when Opcodes::HALT
        return

      when Opcodes::ADD
        set_value(3, get_value(1) + get_value(2))
        @pc += 4

      when Opcodes::MULT
        set_value(3, get_value(1) * get_value(2))
        @pc += 4

      when Opcodes::READ
        input = take_input
        unless input
          puts "Error: no input available"
          exit 1
        end
        set_value(1, input)
        @pc += 2

      when Opcodes::WRITE
        yield get_value(1)
        @pc += 2

      when Opcodes::JUMP_IF_TRUE
        if get_value(1) != 0
          @pc = get_value(2)
        else
          @pc += 3
        end

      when Opcodes::JUMP_IF_FALSE
        if get_value(1) == 0
          @pc = get_value(2)
        else
          @pc += 3
        end

      when Opcodes::LESS_THAN
        set_value(3, get_value(1) < get_value(2) ? 1 : 0)
        @pc += 4

      when Opcodes::EQUALS
        set_value(3, get_value(1) == get_value(2) ? 1 : 0)
        @pc += 4

      else
        puts "Error: #{opcode} is not a valid opcode"
        exit 1

      end
    end
  end
end

input = ARGV.shift.to_i
initial_memory = gets.split(",").map(&:to_i)

computer = Intcode.new(initial_memory)
computer.add_input(input)

computer.run_program { |n| puts "Output: #{n}" }

