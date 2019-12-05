module ParameterModes
  POSITION = 0
  IMMEDIATE = 1
end

class RegisterMemory

  def initialize(memory)
    @memory = memory
    @pc = 0
  end

  def opcode
    @memory[@pc] % 100
  end

  def get_value(offset)
    contents = @memory[@pc + offset]

    case parameter_mode(offset)
    when ParameterModes::POSITION
      @memory[contents]
    when ParameterModes::IMMEDIATE
      contents
    else
      puts "Error: invalid mode at PC = #{@pc}, offset = #{offset}"
      exit 1
    end
  end

  def set_value(offset, value)
    @memory[@memory[@pc + offset]] = value
  end

  def increment_pc(inc)
    @pc += inc
  end

  def jump_to_offset(offset)
    @pc = get_value(offset)
  end

  def set_pc(new_pc)
    @pc = new_pc
  end

  def parameter_mode(offset)
    (@memory[@pc] / (10 ** (offset + 1))) % 10
  end
end

class Intcode

  def initialize(initial_memory)
    @memory = initial_memory.dup
    @register_memory = RegisterMemory.new(@memory)
    @input = []
  end

  def add_input(new_input)
    @input.push(new_input)
  end

  def run_program(&proc)
    loop do
      opcode = @register_memory.opcode
      case opcode
      when 99
        return
      when 4
        write proc
      else
        send $INSTRUCTIONS_FROM_OPCODES[opcode]
      end
    end
  end

  $INSTRUCTIONS_FROM_OPCODES = {
    1 => :add,
    2 => :mult,
    3 => :read,
    # 4 => :write has custom handling
    5 => :jump_if_true,
    6 => :jump_if_false,
    7 => :less_than,
    8 => :equals,
    # 99 = halt has custom handling
  }

  def add
    @register_memory.set_value(3, @register_memory.get_value(1) + @register_memory.get_value(2))
    @register_memory.increment_pc(4)
  end

  def mult
    @register_memory.set_value(3, @register_memory.get_value(1) * @register_memory.get_value(2))
    @register_memory.increment_pc(4)
  end

  def read
    input = @input.shift
    unless input
      puts "Error: no input available"
      exit 1
    end
    @register_memory.set_value(1, input)
    @register_memory.increment_pc(2)
  end

  def write(proc)
    proc.call(@register_memory.get_value(1))
    @register_memory.increment_pc(2)
  end

  def jump_if_true
    if @register_memory.get_value(1) != 0
      @register_memory.jump_to_offset(2)
    else
      @register_memory.increment_pc(3)
    end
  end

  def jump_if_false
    if @register_memory.get_value(1) == 0
      @register_memory.jump_to_offset(2)
    else
      @register_memory.increment_pc(3)
    end
  end

  def less_than
    @register_memory.set_value(3, @register_memory.get_value(1) < @register_memory.get_value(2) ? 1 : 0)
    @register_memory.increment_pc(4)
  end

  def equals
    @register_memory.set_value(3, @register_memory.get_value(1) == @register_memory.get_value(2) ? 1 : 0)
    @register_memory.increment_pc(4)
  end
end

input = ARGV.shift.to_i
initial_memory = gets.split(",").map(&:to_i)

computer = Intcode.new(initial_memory)
computer.add_input(input)

computer.run_program { |n| puts "Output: #{n}" }

