#!/usr/bin/env ruby

require 'set'
require 'pqueue'  # gem install pqueue

class KeyPathSearch
  def initialize(tunnel_map)
    @tunnel_map = tunnel_map
    find_entrance
    find_all_keys
    find_all_paths_between_keys
  end

  def fewest_steps_to_all_keys
    partial_solutions = PQueue.new([{
      distance_so_far: 0,
      location: @entrance,
      keys_held: Set[],
      keys_found_in_order: [],
    }]) { |a, b| b[:distance_so_far] <=> a[:distance_so_far] }
    shortest_distance_found = nil
    shortest_distance_to_states = {}

    until partial_solutions.empty?
      current_attempt = partial_solutions.pop
      distance_so_far = current_attempt[:distance_so_far]

      if shortest_distance_found && shortest_distance_found <= distance_so_far
        return shortest_distance_found
      end

      keys_held = current_attempt[:keys_held]
      if keys_held.size == @key_locations.size
        shortest_distance_found = distance_so_far
        next
      end

      location = current_attempt[:location]
      state = {keys_held: keys_held, location: location}
      shortest_to_here = shortest_distance_to_states[state]
      next if shortest_to_here && shortest_to_here <= distance_so_far
      shortest_distance_to_states[state] = distance_so_far

      @paths_to_keys[location]
        .reject { |path| keys_held.include?(path[:key]) }
        .select { |path| path[:keys_needed] <= keys_held }
        .each do |path|
          partial_solutions << {
            distance_so_far: distance_so_far + path[:distance],
            location: path[:location],
            keys_held: keys_held | Set[path[:key]],
            keys_found_in_order: current_attempt[:keys_found_in_order] + [path[:key]]
          }
        end
    end

    shortest_distance_found
  end

  private

  DIRECTIONS = {
    north: ->(i, j) { [i-1, j] },
    south: ->(i, j) { [i+1, j] },
    east:  ->(i, j) { [i, j+1] },
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
    set_contents(i, j, OPEN_SPACE)
  end

  def find_all_keys
    @key_locations = {}
    @tunnel_map.each_with_index do |row, i|
      (0...row.length).each do |j|
        char = row[j]
        if KEY.include?(char)
          @key_locations[char] = [i,j]
        end
      end
    end
  end

  def find_all_paths_between_keys
    @paths_to_keys = {}
    [@entrance].concat(@key_locations.values).each do |loc|
      @paths_to_keys[loc] = find_all_paths_from_location(loc)
    end
  end

  def find_all_paths_from_location(location)
    starting_contents = contents(*location)
    known_paths = {location => {distance: 0, contents: starting_contents, keys_needed: Set[]}}
    location_queue = [location]
    until location_queue.empty?
      loc = location_queue.shift
      curr_path = known_paths[loc]

      DIRECTIONS.values.each do |move|
        new_loc = move.call(*loc)
        new_contents = contents(*new_loc)
        next if new_contents == '#' || known_paths.has_key?(new_loc)

        location_queue << new_loc

        curr_contents = curr_path[:contents]
        known_paths[new_loc] = {
          distance: curr_path[:distance] + 1,
          contents: new_contents,
          keys_needed: new_keys_needed(curr_path[:keys_needed], curr_contents, starting_contents),
        }
      end
    end
    known_paths
      .select { |_k, v| KEY.include?(v[:contents]) }
      .map do |k, v|
        {
          key: v[:contents],
          keys_needed: v[:keys_needed],
          distance: v[:distance],
          location: k,
        }
      end
  end

  def contents(i, j)
    @tunnel_map[i][j]
  end

  def set_contents(i, j, contents)
    @tunnel_map[i][j] = contents
  end

  def new_keys_needed(curr_keys_needed, curr_contents, starting_contents)
    if starting_contents != curr_contents && (DOOR.include?(curr_contents) || KEY.include?(curr_contents))
      curr_keys_needed | Set[curr_contents.downcase]
    else
      curr_keys_needed
    end
  end
end


tunnel_map = ARGF.read.split("\n")
key_path_search = KeyPathSearch.new(tunnel_map)
fewest_steps = key_path_search.fewest_steps_to_all_keys
puts "Fewest steps to all keys: #{fewest_steps}"

