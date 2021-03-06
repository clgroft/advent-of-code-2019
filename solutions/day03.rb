#!/usr/bin/env ruby

$moves = {
  "U" => ->(x, y) { return x, y+1 },
  "D" => ->(x, y) { return x, y-1 },
  "L" => ->(x, y) { return x-1, y },
  "R" => ->(x, y) { return x+1, y }
}

def wire_distances(wire_codes)
  x, y = 0, 0
  distance_so_far = 0
  all_distances = {}

  wire_codes.each do |code|
    direction, distance = code[0], code[1..-1].to_i
    distance.times do
      x, y = $moves[direction].call(x, y)
      distance_so_far += 1
      all_distances[[x, y]] ||= distance_so_far
    end
  end

  all_distances
end

wire1 = gets.strip.split(",")
wire2 = gets.strip.split(",")

wire1_distance = wire_distances(wire1)
wire2_distance = wire_distances(wire2)

intersections = wire1_distance.keys.select { |k| wire2_distance.has_key?(k) }

shortest_taxicab_distance = intersections.collect { |k| k.map(&:abs).reduce(0, :+) }.min
shortest_wire_distance = intersections.collect { |k| wire1_distance[k] + wire2_distance[k] }.min

puts "Shortest taxicab distance: #{shortest_taxicab_distance}"
puts "Shortest wire distance: #{shortest_wire_distance}"

