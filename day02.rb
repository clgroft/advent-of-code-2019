memory = gets.split(",").map(&:to_i)
memory[1] = 12
memory[2] = 2
# memory = [1,9,10,3,2,3,11,0,99,30,40,50]
pc = 0
loop do
  case memory[pc]
  when 1
    memory[memory[pc+3]] = memory[memory[pc+1]] + memory[memory[pc+2]]
  when 2
    memory[memory[pc+3]] = memory[memory[pc+1]] * memory[memory[pc+2]]
  when 99
    break
  else
    puts "Error: memory[pc] = #{memory[pc]} is not a valid opcode"
    break
  end
  pc += 4
end
puts memory

