#!/usr/bin/env ruby

require 'set'
require_relative 'lib/intcode'


initial_memory = ARGF.gets.strip.split(',').map(&:to_i)
network_computers = 50.times.map { Intcode.new(initial_memory) }
network_computers.each_with_index { |c, i| c.add_input(i) }

nat_x = nil
nat_y = nil
nat_y_values_sent = Set[]

loop do
  if network_computers.all?(&:input_queue_empty?)
    if nat_y && nat_y_values_sent.include?(nat_y)
      puts "First repeated NAT -> 0 Y-value = #{nat_y}"
      exit 0
    end

    nat_y_values_sent << nat_y

    comp_0 = network_computers[0]
    comp_0.add_input(nat_x)
    comp_0.add_input(nat_y)
  end

  network_computers.each do |c|
    c.add_input(-1) if c.input_queue_empty?

    outputs = []
    c.run_program { |out| outputs << out }

    outputs.each_slice(3) do |addr, x, y|
      if addr == 255
        nat_x = x
        nat_y = y
      else
        dest = network_computers[addr]
        dest.add_input(x)
        dest.add_input(y)
      end
    end
  end
end

