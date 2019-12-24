#!/usr/bin/env ruby

require 'set'


def biodiversity(layout)
  layout.flatten
    .zip(25.times.map { |k| 2**k })
    .select { |c, _n| c == '#' }
    .map { |_c, n| n }
    .inject(0, :+)
end

known_biodiversities = Set[]

def each_neighbor(i, j)
  yield [i-1, j] unless i == 0
  yield [i, j-1] unless j == 0
  yield [i, j+1] unless j == 4
  yield [i+1, j] unless i == 4
end

def new_layout(layout)
  num_live_neighbors = Hash.new(0)
  layout.each_with_index do |row, i|
    row.each_with_index
      .select { |cell, _| cell == '#' }
      .each do |_, j|
        each_neighbor(i, j) { |p| num_live_neighbors[p] += 1 }
      end
  end

  5.times.map do |i|
    5.times.map do |j|
      num_neighbors = num_live_neighbors[[i,j]]
      if num_neighbors == 1 || (num_neighbors == 2 && layout[i][j] == '.')
        '#'
      else
        '.'
      end
    end
  end
end

layout = ARGF.each_line.map { |line| line.strip.split('') }
loop do
  biod = biodiversity(layout)
  if known_biodiversities.include?(biod)
    puts "First layout appearing twice has biodiversity = #{biod}"
    break
  end
  known_biodiversities.add(biod)

  layout = new_layout(layout)
end

