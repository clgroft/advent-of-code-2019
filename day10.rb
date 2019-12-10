#!/usr/bin/env ruby

require 'set'

class Array
  def direction_to(other)
    delta_x = other[0] - self[0]
    delta_y = other[1] - self[1]
    scale = delta_x.gcd(delta_y)
    [delta_x / scale, delta_y / scale]
  end

  def taxicab_distance_to(other)
    (other[0] - self[0]).abs + (other[1] - self[1]).abs
  end

  # Ranges from -Math.PI inclusive to Math.PI exclusive
  # starting at straight up (-y direction) and going clockwise
  def compass_heading
    -Math.atan2(*self)
  end
end

asteroids_in_directions = {}
ARGF.each_line.each_with_index do |row, y|
  row.strip.chars
    .each_with_index
    .select { |char, _| char == "#" }
    .each { |_, x| asteroids_in_directions[[x, y]] = Hash.new { |h, k| h[k] = [] } }
end

asteroids_in_directions.each do |this, dirs|
  asteroids_in_directions
    .keys
    .select { |that| that != this }
    .each { |that| dirs[this.direction_to(that)] << that }
end

best_position, asteroids_from_base =
  asteroids_in_directions.max_by { |_pos, dirs| dirs.size }

puts "Most observable asteroids: #{asteroids_from_base.size}"

directions = asteroids_from_base.keys.to_a.sort_by(&:compass_heading)
directions.each do |dir|
  asteroids_from_base[dir] =
    asteroids_from_base[dir].sort_by { |point| best_position.taxicab_distance_to(point) }
end

all_asteroids = []
loop do
  new_asteroids = directions
    .map { |dir| asteroids_from_base[dir].shift }
    .select { |asteroid| asteroid }
  break if new_asteroids.empty?
  all_asteroids.concat(new_asteroids)
end

puts "200th asteroid is at coordinates #{all_asteroids[199]}"

