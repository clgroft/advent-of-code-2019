#!/usr/bin/env ruby

class Miner
  attr_reader :ore_mined

  def initialize(fundamentals)
    @fundamentals = fundamentals
  end

  def mine_for_fuel(count=1)
    @ore_mined = 0
    @surpluses = Hash.new(0)
    mine_for("FUEL", count)
    @ore_mined
  end

  def mine_for(chemical, count)
    if chemical == "ORE"
      @ore_mined += count
      return
    end

    count = check_for_surplus(chemical,count)
    return if count == 0
    produce(chemical, count)
  end

  def check_for_surplus(chemical, count)
    current_surplus = @surpluses[chemical]
    if current_surplus > count
      @surpluses[chemical] -= count
      return 0
    end
    @surpluses.delete(chemical)
    return count - current_surplus
  end

  def produce(chemical, count)
    chemical_info = @fundamentals[chemical]
    multiplier = (count.to_f / chemical_info[:produced]).ceil
    chemical_info[:recipe].each { |ingredient, ing_count| mine_for(ingredient, ing_count * multiplier) }
    @surpluses[chemical] = chemical_info[:produced] * multiplier - count
  end
end

fundamentals = ARGF.each_line.map do |l|
  recipe, full_product = l.strip.split(" => ")
  product_amount, product = full_product.split(" ")
  product_amount = product_amount.to_i
  recipe = recipe.split(", ").map do |chunk|
    input_amount, input_chemical = chunk.split(" ")
    [input_chemical, input_amount.to_i]
  end
  [product, {produced: product_amount, recipe: recipe}]
end.to_h

miner = Miner.new(fundamentals)
ore_needed = miner.mine_for_fuel
puts "Total ore mined for 1 fuel: #{ore_needed} units"

ONE_TRILLION = 10**12
lower_limit_inclusive = ONE_TRILLION / ore_needed
upper_limit_exclusive = lower_limit_inclusive * 2
while miner.mine_for_fuel(upper_limit_exclusive) <= ONE_TRILLION
  upper_limit_exclusive *= 2
end
while upper_limit_exclusive - lower_limit_inclusive > 1
  test_value = (upper_limit_exclusive + lower_limit_inclusive) / 2
  if miner.mine_for_fuel(test_value) <= ONE_TRILLION
    lower_limit_inclusive = test_value
  else
    upper_limit_exclusive = test_value
  end
end

puts "With one trillion ore units, can produce #{lower_limit_inclusive} units of fuel"
