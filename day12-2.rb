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

  def state_by_axis
    pos.zip(vel)
  end
end


def capture_moon_state_by_axis(moons)
  moons.map(&:state_by_axis).transpose
end


INPUT_FORMAT = /<x=(.+), y=(.+), z=(.+)>/
moons = ARGF.each_line.map do |line|
  match = INPUT_FORMAT.match(line.strip)
  Moon.new(*(1..3).map { |i| match[i].to_i })
end
num_steps = 0
starting_state = capture_moon_state_by_axis(moons)
cycle_length = [nil, nil, nil]

loop do
  moons.each do |moon|
    moons.each do |other_moon|
      moon.pull_from(other_moon)
    end
  end
  moons.each { |moon| moon.step_forward }
  num_steps += 1
  current_state = capture_moon_state_by_axis(moons)
  (0...3).each do |n|
    if starting_state[n] == current_state[n]
      cycle_length[n] ||= num_steps
    end
  end
  break if cycle_length.all?
end

complete_cycle_length = cycle_length.inject { |a, b| a.lcm(b) }
puts "Complete cycle length: #{complete_cycle_length}"

