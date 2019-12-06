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
    source_object_to_com = @orbit_centers[source]
    steps = 0
    while source_object_to_com
      source_orbit_distances[source_object_to_com] = steps
      source_object_to_com = @orbit_centers[source_object_to_com]
      steps += 1
    end

    dest_object_to_com = @orbit_centers[dest]
    steps = 0
    while dest_object_to_com
      if source_orbit_distances.has_key?(dest_object_to_com)
        return steps + source_orbit_distances[dest_object_to_com]
      end
      dest_object_to_com = @orbit_centers[dest_object_to_com]
      steps += 1
    end

    nil
  end
end

orbit_tree_from_root = OrbitTreeFromRoot.new
orbit_tree_to_root = OrbitTreeToRoot.new
ARGF.each_line do |line|
  center, satellite = line.strip.split(')')
  orbit_tree_from_root.add_satellite(center, satellite)
  orbit_tree_to_root.add_satellite(center, satellite)
end

puts "Total number of orbits: #{orbit_tree_from_root.total_orbits}"
puts "Total steps from YOU to SAN: #{orbit_tree_to_root.transfer_distance("YOU", "SAN")}"

