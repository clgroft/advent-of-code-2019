module ParameterModes
  POSITION = 0
  IMMEDIATE = 1
end

class RegisterMemory

  def initialize(memory)
    @memory = memory
  end

  def opcode(pc)
    @memory[pc] % 100
  end

  def get_value(pc, offset)
    contents = @memory[pc + offset]

    case parameter_mode(pc, offset)
    when ParameterModes::POSITION
      @memory[contents]
    when ParameterModes::IMMEDIATE
      contents
    else
      puts "Error: invalid mode at PC = #{pc}, offset = #{offset}"
      exit 1
    end
  end

  def parameter_mode(pc, offset)
    (@memory[pc] / (10 ** (offset + 1))) % 10
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
    @pc = 0
    loop do
      opcode = @register_memory.opcode(@pc)
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
    set_value(3, @register_memory.get_value(@pc, 1) + @register_memory.get_value(@pc, 2))
    @pc += 4
  end

  def mult
    set_value(3, @register_memory.get_value(@pc, 1) * @register_memory.get_value(@pc, 2))
    @pc += 4
  end

  def read
    input = @input.shift
    unless input
      puts "Error: no input available"
      exit 1
    end
    set_value(1, input)
    @pc += 2
  end

  def write(proc)
    proc.call(@register_memory.get_value(@pc, 1))
    @pc += 2
  end

  def jump_if_true
    if @register_memory.get_value(@pc, 1) != 0
      @pc = @register_memory.get_value(@pc, 2)
    else
      @pc += 3
    end
  end

  def jump_if_false
    if @register_memory.get_value(@pc, 1) == 0
      @pc = @register_memory.get_value(@pc, 2)
    else
      @pc += 3
    end
  end

  def less_than
    set_value(3, @register_memory.get_value(@pc, 1) < @register_memory.get_value(@pc, 2) ? 1 : 0)
    @pc += 4
  end

  def equals
    set_value(3, @register_memory.get_value(@pc, 1) == @register_memory.get_value(@pc, 2) ? 1 : 0)
    @pc += 4
  end

  def set_value(offset, value)
    @memory[@memory[@pc + offset]] = value
  end

  def parameter_mode(offset)
    (@memory[@pc] / (10 ** (offset + 1))) % 10
  end
end

input = ARGV.shift.to_i
initial_memory = gets.split(",").map(&:to_i)

computer = Intcode.new(initial_memory)
computer.add_input(input)

computer.run_program { |n| puts "Output: #{n}" }

