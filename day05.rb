class Intcode

  HALT_OPCODE = 99
  ADD_OPCODE = 1
  MULT_OPCODE = 2
  READ_OPCODE = 3
  WRITE_OPCODE = 4

  POSITION_MODE = 0
  IMMEDIATE_MODE = 1

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
    when POSITION_MODE
      get_register(contents)
    when IMMEDIATE_MODE
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
      when HALT_OPCODE
        return

      when ADD_OPCODE
        set_value(3, get_value(1) + get_value(2))
        @pc += 4

      when MULT_OPCODE
        set_value(3, get_value(1) * get_value(2))
        @pc += 4

      when READ_OPCODE
        input = take_input
        unless input
          puts "Error: no input available"
          exit 1
        end
        set_value(1, input)
        @pc += 2

      when WRITE_OPCODE
        yield get_value(1)
        @pc += 2

      else
        puts "Error: #{opcode} is not a valid opcode"
        exit 1

      end
    end
  end
end

initial_memory = gets.split(",").map(&:to_i)
computer = Intcode.new(initial_memory)
computer.add_input(1)
computer.run_program { |n| puts "Output: #{n}" }

