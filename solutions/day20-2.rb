#!/usr/bin/env ruby

require 'set'

input = ARGF.each_line.map(&:chomp)
open_passages = input.each_with_index
  .map do |row, i|
    row.chars.each_with_index
      .select { |c, _j| c == '.' }
      .map    { |_c, j| [i,j] }
  end.flatten(1).to_set

labeled_passages = Hash.new { |h, k| h[k] = [] }
input.each_with_index do |row, i|
  row.to_enum(:scan, /([A-Z]{2})(\.)/)
    .map  { Regexp.last_match }
    .each { |match_data| labeled_passages[match_data[1]] << [i, match_data.begin(2)] }
  row.to_enum(:scan, /(\.)([A-Z]{2})/)
    .map  { Regexp.last_match }
    .each { |match_data| labeled_passages[match_data[2]] << [i, match_data.begin(1)] }
end
transposed_input = input.map(&:chars).transpose.map(&:join)
transposed_input.each_with_index do |col, j|
  col.to_enum(:scan, /([A-Z]{2})(\.)/)
    .map  { Regexp.last_match }
    .each { |match_data| labeled_passages[match_data[1]] << [match_data.begin(2), j] }
  col.to_enum(:scan, /(\.)([A-Z]{2})/)
    .map  { Regexp.last_match }
    .each { |match_data| labeled_passages[match_data[2]] << [match_data.begin(1), j] }
end

left_edge = 2
right_edge = input[0].length - 3
top_edge = 2
bottom_edge = input.length - 3

start_point = labeled_passages.delete('AA')[0]
end_point = labeled_passages.delete('ZZ')[0]
conditional_walls = [start_point, end_point]

warp_points = labeled_passages
  .values
  .map { |a, b| [[a,b], [b,a]] }
  .flatten(1)
  .to_h

connected_passages = open_passages
  .map do |pos|
    i, j = pos
    neighbors = [[i+1,j], [i-1,j], [i,j+1], [i,j-1]].select { |p| open_passages.include?(p) }
    [pos, neighbors.map { |new_pos| {new_position: new_pos, nesting_delta: 0} }]
  end.to_h
warp_points.each do |src, dst|
  is_going_inward =
    dst[0] == top_edge    ||
    dst[0] == bottom_edge ||
    dst[1] == left_edge   ||
    dst[1] == right_edge
  connected_passages[src] << {new_position: dst, nesting_delta: (is_going_inward ? 1 : -1)}
end

starting_state = {position: start_point, nesting: 0}
distances = {starting_state => 0}
state_queue = [starting_state]
until state_queue.empty?
  curr_state = state_queue.shift
  curr_distance = distances[curr_state]
  connected_passages[curr_state[:position]]
    .map do |new_rec_pos|
      {
        position: new_rec_pos[:new_position],
        nesting: curr_state[:nesting] + new_rec_pos[:nesting_delta],
      }
    end
    .reject { |dst| distances.has_key?(dst) }
    .reject { |dst| dst[:nesting] < 0 }
    .reject { |dst| conditional_walls.include?(dst[:position]) && dst[:nesting] > 0 }
    .each do |dst|
      new_distance = curr_distance + 1
      if dst[:position] == end_point
        puts "Distance to end point: #{new_distance}"
        exit 0
      end
      distances[dst] = new_distance
      state_queue << dst
    end
end
puts "No path to end point found"
exit 1

