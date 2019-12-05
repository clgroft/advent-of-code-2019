module ParameterModes
  POSITION = 0
  IMMEDIATE = 1
end

class InternalState

  def initialize(memory)
    @memory = memory
    @pc = 0
  end

  def opcode
    @memory[@pc] % 100
  end

  def get_from_offset(offset)
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

  def set_to_offset(offset, value)
    @memory[@memory[@pc + offset]] = value
  end

  def advance_pc(inc)
    @pc += inc
  end

  def jump_to_offset(offset)
    @pc = get_from_offset(offset)
  end

  def parameter_mode(offset)
    (@memory[@pc] / (10 ** (offset + 1))) % 10
  end
end

class Intcode

  def initialize(initial_memory)
    @state = InternalState.new(initial_memory.dup)
    @input = []
  end

  def add_input(new_input)
    @input.push(new_input)
  end

  def run_program(&proc)
    loop do
      opcode = @state.opcode
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
    @state.set_to_offset(3, @state.get_from_offset(1) + @state.get_from_offset(2))
    @state.advance_pc(4)
  end

  def mult
    @state.set_to_offset(3, @state.get_from_offset(1) * @state.get_from_offset(2))
    @state.advance_pc(4)
  end

  def read
    input = @input.shift
    unless input
      puts "Error: no input available"
      exit 1
    end
    @state.set_to_offset(1, input)
    @state.advance_pc(2)
  end

  def write(proc)
    proc.call(@state.get_from_offset(1))
    @state.advance_pc(2)
  end

  def jump_if_true
    if @state.get_from_offset(1) != 0
      @state.jump_to_offset(2)
    else
      @state.advance_pc(3)
    end
  end

  def jump_if_false
    if @state.get_from_offset(1) == 0
      @state.jump_to_offset(2)
    else
      @state.advance_pc(3)
    end
  end

  def less_than
    @state.set_to_offset(3, @state.get_from_offset(1) < @state.get_from_offset(2) ? 1 : 0)
    @state.advance_pc(4)
  end

  def equals
    @state.set_to_offset(3, @state.get_from_offset(1) == @state.get_from_offset(2) ? 1 : 0)
    @state.advance_pc(4)
  end
end

input = ARGV.shift.to_i
initial_memory = gets.split(",").map(&:to_i)

computer = Intcode.new(initial_memory)
computer.add_input(input)

computer.run_program { |n| puts "Output: #{n}" }

