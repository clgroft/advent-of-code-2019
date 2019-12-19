#!/usr/bin/env ruby

require 'set'
require 'pqueue'  # gem install pqueue

class KeyPathSearch
  def initialize(tunnel_map)
    @tunnel_map = tunnel_map

    find_entrance
    find_all_keys
    find_all_paths_between_keys
    reset_distance_cache
  end

  def prepare_for_second_part
    add_new_walls
    add_new_entrances
    # Have to rebuild the paths and cache since the map has been modified
    find_all_paths_between_keys
    reset_distance_cache
  end

  def fewest_steps_to_all_keys(locations=@entrances, keys_held=Set[])
    return 0 if keys_held.size == @key_locations.size

    @known_distances_from_states[{locations: locations, keys_held: keys_held}] ||=
      locations.each_with_index.map do |location, i|
        paths_ending_in_accessible_keys(location, keys_held)
          .map do |path|
            path[:distance] +
              fewest_steps_to_all_keys(
                move_robot_along_path(locations, i, path[:location]),
                keys_held | Set[path[:key]])
          end
      end.flatten.min
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
    @initial_entrance = @tunnel_map.each_with_index
      .map { |row, i| [i, (row =~ /@/)] }
      .select { |_i, j| j }
      .first
    i, j = @initial_entrance
    set_contents(i, j, OPEN_SPACE)
    @entrances = [@initial_entrance]
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
    @entrances.dup.concat(@key_locations.values).each do |loc|
      @paths_to_keys[loc] = find_all_paths_from_location(loc)
    end
  end

  def reset_distance_cache
    @known_distances_from_states = {}
  end

  def add_new_walls
    i, j = @initial_entrance
    @tunnel_map[i-1][j] = '#'
    @tunnel_map[i][j-1] = '#'
    @tunnel_map[i][j] = '#'
    @tunnel_map[i][j+1] = '#'
    @tunnel_map[i+1][j] = '#'
  end

  def add_new_entrances
    i, j = @initial_entrance
    @entrances = [ [i-1,j-1], [i-1,j+1], [i+1,j-1], [i+1,j+1] ]
  end

  def find_all_paths_from_location(location)
    starting_contents = contents(*location)
    known_paths = {location => {distance: 0, contents: starting_contents, keys_needed: Set[]}}
    location_queue = [location]
    until location_queue.empty?
      loc = location_queue.shift
      curr_path = known_paths[loc]

      DIRECTIONS.values
        .map { |move| move.call(*loc) }
        .reject { |new_loc| is_wall?(new_loc) || known_paths.has_key?(new_loc) }
        .each do |new_loc|
          location_queue << new_loc
          known_paths[new_loc] = {
            distance: curr_path[:distance] + 1,
            contents: contents(*new_loc),
            keys_needed: new_keys_needed(curr_path[:keys_needed], curr_path[:contents], starting_contents),
          }
        end
    end

    known_paths
      .select { |_k, v| KEY.include?(v[:contents]) }
      .reject { |_k, v| v[:distance] == 0 }
      .map do |k, v|
        {
          key: v[:contents],
          keys_needed: v[:keys_needed],
          distance: v[:distance],
          location: k,
        }
      end
  end

  def is_wall?(loc)
    contents(*loc) == '#'
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

  def paths_ending_in_accessible_keys(location, keys_held)
    @paths_to_keys[location]
      .reject { |path| keys_held.include?(path[:key]) }
      .select { |path| path[:keys_needed] <= keys_held }
  end

  def move_robot_along_path(locations, i, new_position)
    new_locations = locations.dup
    new_locations[i] = new_position
    new_locations
  end
end


tunnel_map = ARGF.read.split("\n")
key_path_search = KeyPathSearch.new(tunnel_map)
fewest_steps = key_path_search.fewest_steps_to_all_keys
puts "Fewest steps to all keys (before partition): #{fewest_steps}"

key_path_search.prepare_for_second_part
fewest_steps = key_path_search.fewest_steps_to_all_keys
puts "Fewest steps to all keys (after partition): #{fewest_steps}"

