#!/usr/bin/env ruby

require 'set'


class KeyPathSearch
  def initialize(tunnel_map)
    @tunnel_map = tunnel_map
    find_entrance
    @num_keys = tunnel_map.map { |row| row.scan(/[a-z]/).size }.inject(:+)
  end

  def fewest_steps_to_all_keys(location=@entrance, keys_held=Set[], keys_to_find=@num_keys)
    return 0 if keys_to_find == 0
    accessible_keys = find_accessible_keys(location, keys_held)
    keys_left_to_find = keys_to_find - 1
    accessible_keys.map do |key|
      key[:distance] + fewest_steps_to_all_keys(
        key[:location],
        keys_held | [key[:name]],
        keys_left_to_find)
    end.min
  end

  private

  DIRECTIONS = {
    north: ->(i, j) { [i-1, j] },
    east:  ->(i, j) { [i, j+1] },
    south: ->(i, j) { [i+1, j] },
    west:  ->(i, j) { [i, j-1] },
  }

  OPEN_SPACE = '.'
  DOOR = ('A'..'Z')
  KEY = ('a'..'z')

  def find_entrance
    @entrance = @tunnel_map.each_with_index
      .map { |row, i| [i, (row =~ /@/)] }
      .select { |_i, j| j }
      .first
    i, j = @entrance
    @tunnel_map[i][j] = OPEN_SPACE
  end

  def find_accessible_keys(location, keys_held)
    accessible_keys = []
    known_distances = {location => 0}
    location_queue = [location]
    until location_queue.empty?
      loc = location_queue.shift
      DIRECTIONS.values.each do |move|
        new_loc = move.call(*loc)
        next if known_distances.has_key?(new_loc)
        new_distance = known_distances[loc] + 1
        known_distances[new_loc] = new_distance
        i, j = *new_loc
        contents = @tunnel_map[i][j]
        case contents
        when OPEN_SPACE
          location_queue << new_loc
        when DOOR
          location_queue << new_loc if keys_held.include?(contents.downcase)
        when KEY
          if keys_held.include?(contents)
            location_queue << new_loc
          else
            accessible_keys << {name: contents, location: new_loc, distance: new_distance}
          end
        end
      end
    end
    accessible_keys
  end
end


tunnel_map = ARGF.read.split("\n")
key_path_search = KeyPathSearch.new(tunnel_map)
fewest_steps = key_path_search.fewest_steps_to_all_keys
puts "Fewest steps to all keys: #{fewest_steps}"

