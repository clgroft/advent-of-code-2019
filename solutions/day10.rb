#!/usr/bin/env ruby

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
# Set up keys (where are all the asteroids?)
ARGF.each_line.each_with_index do |row, y|
  row.strip.chars
    .each_with_index
    .select { |char, _| char == "#" }
    .each { |_, x| asteroids_in_directions[[x, y]] = Hash.new { |h, k| h[k] = [] } }
end
# and values (what are their relative directions?)
asteroids_in_directions.each do |this, dirs|
  asteroids_in_directions
    .keys
    .reject { |that| that == this }
    .each { |that| dirs[this.direction_to(that)] << that }
end

# For each direction from an asteroid that has at least one asteroid on it,
# there is a unique closest (therefore visible) asteroid
best_position, asteroids_from_base =
  asteroids_in_directions.max_by { |_pos, dirs| dirs.size }

puts "Most observable asteroids: #{asteroids_from_base.size}"

# We fire the laser in each direction, clockwise starting from vertical,
# each time targeting the closest remaining asteroid
asteroid_queues = asteroids_from_base
  .sort_by { |direction, _asteroids| direction.compass_heading }
  .map do |_direction, asteroids|
    asteroids.sort_by { |point| best_position.taxicab_distance_to(point) }
  end

asteroids_in_destruction_order = []
until asteroid_queues.empty?
  asteroids_in_destruction_order.concat(asteroid_queues.map(&:shift))
  asteroid_queues = asteroid_queues.reject(&:empty?)
end

puts "200th asteroid destroyed is at coordinates #{asteroids_in_destruction_order[199]}"

