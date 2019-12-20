#!/usr/bin/env ruby

require 'set'

input = ARGF.each_line.map(&:chomp)
open_passages = input.each_with_index
  .map do |row, i|
    row.chars.each_with_index
      .select { |c, _j| c == '.' }
      .map { |_c, j| [i,j] }
  end.flatten(1).to_set

labeled_passages = Hash.new { |h, k| h[k] = [] }
input.each_with_index do |row, i|
  row.to_enum(:scan, /([A-Z]{2})(\.)/)
    .map { Regexp.last_match }
    .each { |match_data| labeled_passages[match_data[1]] << [i, match_data.begin(2)] }
  row.to_enum(:scan, /(\.)([A-Z]{2})/)
    .map { Regexp.last_match }
    .each { |match_data| labeled_passages[match_data[2]] << [i, match_data.begin(1)] }
end
transposed_input = input.map(&:chars).transpose.map(&:join)
transposed_input.each_with_index do |col, j|
  col.to_enum(:scan, /([A-Z]{2})(\.)/)
    .map { Regexp.last_match }
    .each { |match_data| labeled_passages[match_data[1]] << [match_data.begin(2), j] }
  col.to_enum(:scan, /(\.)([A-Z]{2})/)
    .map { Regexp.last_match }
    .each { |match_data| labeled_passages[match_data[2]] << [match_data.begin(1), j] }
end

start_point = labeled_passages.delete('AA')[0]
end_point = labeled_passages.delete('ZZ')[0]
warp_points = labeled_passages
  .values
  .map { |a, b| [[a,b], [b,a]] }
  .flatten(1)
  .to_h

connected_passages = open_passages
  .map do |pos|
    i, j = pos
    neighbors = [[i+1,j], [i-1,j], [i,j+1], [i,j-1]].select { |p| open_passages.include?(p) }
    [pos, neighbors]
  end.to_h
warp_points.each { |src, dst| connected_passages[src] << dst }

distances = {start_point => 0}
point_queue = [start_point]
until point_queue.empty?
  point = point_queue.shift
  curr_distance = distances[point]
  connected_passages[point]
    .reject { |dst| distances.has_key?(dst) }
    .each do |dst|
      new_distance = curr_distance + 1
      if dst == end_point
        puts "Distance to end point: #{new_distance}"
        exit 0
      end
      distances[dst] = new_distance
      point_queue << dst
    end
end
puts "No path to end point found"
exit 1

