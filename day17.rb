#!/usr/bin/env ruby

require_relative 'lib/intcode'

initial_memory = gets.split(",").map(&:to_i)
computer = Intcode.new(initial_memory)

camera_feed = []
computer.run_program { |n| camera_feed << n.chr }
picture = camera_feed.join
puts picture

picture_array = picture.split("\n").map { |l| l.split('') }
num_rows = picture_array.length
num_columns = picture_array[0].length
alignment_params_sum =
  (1..(num_rows - 2)).map do |y|
    y * (1..(num_columns - 2)).select do |x|
      picture_array[y][x] == '#' &&
        picture_array[y][x-1] == '#' &&
        picture_array[y][x+1] == '#' &&
        picture_array[y-1][x] == '#' &&
        picture_array[y+1][x] == '#'
    end.inject(0, :+)
  end.inject(0, :+)
puts "Sum of alignment parameters: #{alignment_params_sum}"

