#!/usr/bin/env ruby

require_relative 'lib/intcode'


initial_memory = ARGF.gets.strip.split(',').map(&:to_i)
network_computers = 50.times.map { Intcode.new(initial_memory) }
network_computers.each_with_index { |c, i| c.add_input(i) }

loop do
  network_computers.each do |c|
    c.add_input(-1) if c.input_queue_empty?

    outputs = []
    c.run_program { |out| outputs << out }

    outputs.each_slice(3) do |addr, x, y|
      if addr == 255
        puts "Packet to 255 found; Y = #{y}"
        exit 0
      end

      dest = network_computers[addr]
      dest.add_input(x)
      dest.add_input(y)
    end
  end
end

