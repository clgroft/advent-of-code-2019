module ParameterModes
  POSITION = 0
  IMMEDIATE = 1
end

# Stores main memory and program counter.  Allows access to memory via offsets
# and allows users to advance the PC and jump to positions given by current
# memory contents.
class InternalState

  def initialize(memory)
    @memory = memory
    @pc = 0
  end

  def opcode
    @memory[@pc] % 100
  end

  # Whether we want the literal value in memory or the value it points to
  # depends on the memory contents at the program counter, which is why we pair
  # them in a single class and why this get method is more complex than most.
  def get(offset)
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

  # In contrast to get, we always want to set at the position that our memory
  # location points to, not at the memory location itself.
  def set(offset, value)
    @memory[@memory[@pc + offset]] = value
  end

  # After an instruction, the program counter must always be advanced past the
  # parameters to that instruction (unless the instruction caused a jump).
  def advance_pc(inc)
    @pc += inc
  end

  def jump(offset)
    @pc = get(offset)
  end

  def parameter_mode(offset)
    (@memory[@pc] / (10 ** (offset + 1))) % 10
  end
end

# Implements the desired operations on InternalState.
class CPU

  def initialize(state)
    @state = state
    @input = []
  end

  def add_input(new_input)
    @input.push(new_input)
  end

  def add
    @state.set(3, @state.get(1) + @state.get(2))
    @state.advance_pc(4)
  end

  def mult
    @state.set(3, @state.get(1) * @state.get(2))
    @state.advance_pc(4)
  end

  def read
    input = @input.shift
    unless input
      puts "Error: no input available"
      exit 1
    end
    @state.set(1, input)
    @state.advance_pc(2)
  end

  def write(proc)
    proc.call(@state.get(1))
    @state.advance_pc(2)
  end

  def jump_if_true
    if @state.get(1) != 0
      @state.jump(2)
    else
      @state.advance_pc(3)
    end
  end

  def jump_if_false
    if @state.get(1) == 0
      @state.jump(2)
    else
      @state.advance_pc(3)
    end
  end

  def less_than
    @state.set(3, @state.get(1) < @state.get(2) ? 1 : 0)
    @state.advance_pc(4)
  end

  def equals
    @state.set(3, @state.get(1) == @state.get(2) ? 1 : 0)
    @state.advance_pc(4)
  end
end

# The main abstraction for the machine.  Translates opcodes into instructions
# and sends them to the CPU.
class Intcode

  def initialize(initial_memory)
    @state = InternalState.new(initial_memory.dup)
    @cpu = CPU.new(@state)
  end

  def add_input(new_input)
    @cpu.add_input(new_input)
  end

  def run_program(&proc)
    loop do
      opcode = @state.opcode
      case opcode
      when 99
        return
      when 4
        @cpu.write(proc)
      else
        @cpu.send($INSTRUCTIONS_FROM_OPCODES[opcode])
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
end

