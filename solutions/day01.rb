#!/usr/bin/env ruby

def basic_fuel_cost(weight)
  weight / 3 - 2
end

def total_fuel_cost(weight)
  total_cost = 0
  partial_fuel_cost = basic_fuel_cost(weight)
  while partial_fuel_cost > 0
    total_cost += partial_fuel_cost
    partial_fuel_cost = basic_fuel_cost(partial_fuel_cost)
  end
  total_cost
end

weights = ARGF.each_line.map { |line| line.strip.to_i }

part1_cost = weights.map { |w| basic_fuel_cost(w) }.inject(0, :+)
puts "Basic fuel cost: #{part1_cost}"

part2_cost = weights.map { |w| total_fuel_cost(w) }.inject(0, :+)
puts "Total fuel cost: #{part2_cost}"

