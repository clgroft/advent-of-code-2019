#!/usr/bin/env ruby

require 'set'


def each_neighbor_above(point)
  if point[:row] == 0
    yield ({level: point[:level] - 1, row: 1, col: 2})
  elsif point[:row] == 3 && point[:col] == 2
    (0..4).each { |col| yield ({level: point[:level] + 1, row: 4, col: col}) }
  else
    yield ({level: point[:level], row: point[:row] - 1, col: point[:col]})
  end
end

def each_neighbor_to_left(point)
  if point[:col] == 0
    yield ({level: point[:level] - 1, row: 2, col: 1})
  elsif point[:col] == 3 && point[:row] == 2
    (0..4).each { |row| yield ({level: point[:level] + 1, row: row, col: 4}) }
  else
    yield ({level: point[:level], row: point[:row], col: point[:col] - 1})
  end
end

def each_neighbor_to_right(point)
  if point[:col] == 4
    yield ({level: point[:level] - 1, row: 2, col: 3})
  elsif point[:col] == 1 && point[:row] == 2
    (0..4).each { |row| yield ({level: point[:level] + 1, row: row, col: 0}) }
  else
    yield ({level: point[:level], row: point[:row], col: point[:col] + 1})
  end
end

def each_neighbor_below(point)
  if point[:row] == 4
    yield ({level: point[:level] - 1, row: 3, col: 2})
  elsif point[:row] == 1 && point[:col] == 2
    (0..4).each { |col| yield ({level: point[:level] + 1, row: 0, col: col}) }
  else
    yield ({level: point[:level], row: point[:row] + 1, col: point[:col]})
  end
end

def each_neighbor(point)
  each_neighbor_above(point)    { |p| yield p }
  each_neighbor_to_left(point)  { |p| yield p }
  each_neighbor_to_right(point) { |p| yield p }
  each_neighbor_below(point)    { |p| yield p }
end


def new_layout(layout)
  num_live_neighbors = Hash.new(0)
  layout.each do |point|
    each_neighbor(point) { |p| num_live_neighbors[p] += 1 }
  end

  num_live_neighbors.select do |point, num_neighbors|
    num_neighbors == 1 || (num_neighbors == 2 && !layout.include?(point))
  end.map { |point, _| point }.to_set
end


layout = ARGF.each_line
  .each_with_index
  .map do |row, i|
    row.split('').each_with_index
      .select { |c, _| c == '#' }
      .map { |_, j| {level: 0, row: i, col: j} }
  end.flatten.to_set

200.times { layout = new_layout(layout) }

puts "Number of bugs: #{layout.size}"

