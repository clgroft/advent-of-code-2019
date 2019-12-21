#!/usr/bin/env ruby

require_relative 'lib/intcode'


def run_springcode(part, computer, springcode)
  springcode = springcode.map { |l| l + "\n" }.join
  computer = computer.dup
  springcode.chars.map(&:ord).each { |code| computer.add_input(code) }

  outputs = []
  computer.run_program { |n| outputs << n }

  hull_damage = outputs.last
  if hull_damage > 255
    puts "Part #{part} succeeded!  Hull damage: #{hull_damage}"
  else
    puts "Part #{part} failed:"
    puts outputs.map(&:chr).join
  end
end


initial_memory = gets.split(",").map(&:to_i)
computer = Intcode.new(initial_memory)
computer.run_program { |_n| }  # "print" prompt

run_springcode(1, computer, [
  "NOT J T", # T = true
  "AND A T",
  "AND B T",
  "AND C T", # T = A & B & C = "no hole to jump"
  "NOT T J", # J = ~(A & B & C) = "a hole to jump"
  "AND D J", # J = ~(A & B & C) & D = "a hole and a place to land"
  "WALK",
])

run_springcode(2, computer, [
  "NOT T J", # T = false, J = true
  "AND A J",
  "AND B J",
  "AND C J", # J = A & B & C = "no hole to jump"
  "NOT J T", # T = ~(A & B & C) = "a hole to jump"
  "AND T J", # J = false
  "OR E J",  # J = E = "a place to walk after jump"
  "OR H J",  # H = "a place to jump after the first jump"
  "AND D J",
  "AND T J", # J = "a hole, a landing spot, and a place to walk or jump after"
  "RUN",
])

