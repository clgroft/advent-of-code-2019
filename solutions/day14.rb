#!/usr/bin/env ruby


class Miner
  def initialize(reactions)
    @reactions = reactions
  end

  def ore_for_fuel(count=1)
    @ore_mined = 0
    @surpluses = Hash.new(0)
    consume("FUEL", count)
    @ore_mined
  end

  private

  def consume(chemical, count)
    if chemical == "ORE"
      @ore_mined += count
    else
      units_to_produce = count - @surpluses[chemical]
      produce_at_least(chemical, units_to_produce) if units_to_produce > 0
      @surpluses[chemical] -= count
    end
  end

  def produce_at_least(chemical, count)
    chemical_info = @reactions[chemical]
    reaction_count = (count.to_f / chemical_info[:produced]).ceil
    chemical_info[:recipe].each do |ingredient, ing_count|
      consume(ingredient, ing_count * reaction_count)
    end
    @surpluses[chemical] += chemical_info[:produced] * reaction_count
  end
end


reactions = ARGF.each_line.map do |l|
  recipe, full_product = l.strip.split(" => ")
  product_amount, product = full_product.split(" ")
  product_amount = product_amount.to_i
  recipe = recipe.split(", ").map do |chunk|
    input_amount, input_chemical = chunk.split(" ")
    [input_chemical, input_amount.to_i]
  end
  [product, {produced: product_amount, recipe: recipe}]
end.to_h
miner = Miner.new(reactions)

# Part 1: how much for one unit of fuel?
ore_needed = miner.ore_for_fuel
puts "One unit of fuel requires #{ore_needed} units of ore"

# Part 2: how many units of fuel from 10**12 units of ore?
# Binary search is fast enough here
# (there are probably faster ways using better estimates)
ONE_TRILLION = 10**12

min_inclusive = ONE_TRILLION / ore_needed
max_exclusive = min_inclusive * 2
max_exclusive *= 2 while miner.ore_for_fuel(max_exclusive) <= ONE_TRILLION

while max_exclusive - min_inclusive > 1
  test_value = (max_exclusive + min_inclusive) / 2
  if miner.ore_for_fuel(test_value) <= ONE_TRILLION
    min_inclusive = test_value
  else
    max_exclusive = test_value
  end
end

puts "One trillion units of ore can produce #{min_inclusive} units of fuel"

