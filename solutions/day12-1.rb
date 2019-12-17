#!/usr/bin/env ruby

def sum_of_magnitudes(arr)
  arr.map(&:abs).inject(0, :+)
end


class Moon
  attr_accessor :pos, :vel

  def initialize(x, y, z)
    @pos = [x, y, z]
    @vel = [0, 0, 0]
  end

  def to_s
    "position #{pos}, velocity #{vel}"
  end

  def pull_from(other_moon)
    delta = pos.zip(other_moon.pos).map { |x0, x1| x1 <=> x0 }
    self.vel = vel.zip(delta).map { |v, d| v + d }
  end

  def step_forward
    self.pos = pos.zip(vel).map { |x, v| x + v }
  end

  def energy
    potential_energy * kinetic_energy
  end

  def potential_energy
    sum_of_magnitudes(pos)
  end

  def kinetic_energy
    sum_of_magnitudes(vel)
  end
end


INPUT_FORMAT = /<x=(.+), y=(.+), z=(.+)>/
moons = ARGF.each_line.map do |line|
  match = INPUT_FORMAT.match(line.strip)
  Moon.new(*(1..3).map { |i| match[i].to_i })
end

1000.times do
  moons.each do |moon|
    moons.each do |other_moon|
      moon.pull_from(other_moon)
    end
  end
  moons.each { |moon| moon.step_forward }
end

total_energy = moons.map(&:energy).inject(0, :+)
puts "Total energy: #{total_energy}"

