#!/usr/bin/env ruby

class OrbitTreeFromRoot
  def initialize
    @satellites = Hash.new { |h, k| h[k] = [] }
  end

  def add_satellite(center, satellite)
    @satellites[center].push(satellite)
  end

  def total_orbits
    @orbit_count = 0
    orbit_count_dfs("COM", 0)
    @orbit_count
  end

  def orbit_count_dfs(object, length_to_com)
    @orbit_count += length_to_com
    if @satellites.has_key?(object)
      sat_length_to_com = length_to_com + 1
      @satellites[object].each { |sat| orbit_count_dfs(sat, sat_length_to_com) }
    end
  end
end

class OrbitTreeToRoot
  def initialize
    @orbit_centers = {}
  end

  def add_satellite(center, satellite)
    @orbit_centers[satellite] = center
  end

  def transfer_distance(source, dest)
    source_orbit_distances = {}
    each_object_to_com(source) { |object, steps| source_orbit_distances[object] = steps }
    each_object_to_com(dest) do |object, steps|
      source_steps = source_orbit_distances[object]
      return steps + source_steps if source_steps
    end
    nil
  end

  def each_object_to_com(source)
    object = @orbit_centers[source]
    steps = 0
    while object
      yield object, steps
      object = @orbit_centers[object]
      steps += 1
    end
  end
end

from_root = OrbitTreeFromRoot.new
to_root = OrbitTreeToRoot.new
ARGF.each_line do |line|
  center, satellite = line.strip.split(')')
  from_root.add_satellite(center, satellite)
  to_root.add_satellite(center, satellite)
end

puts "Total number of orbits: #{from_root.total_orbits}"
puts "Total steps from YOU to SAN: #{to_root.transfer_distance("YOU", "SAN")}"

