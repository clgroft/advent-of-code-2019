#!/usr/bin/env ruby


# Part 1
# The FFT is almost but not quite a matrix multiplication,
# so we have to do it the hard way.
class FFT
  attr_reader :signal

  def initialize(starting_signal)
    @signal = starting_signal
    calculate_parameters(starting_signal.length)
  end

  def drop(n)
    @signal = @signal.drop(n)
    @parameters = @parameters.drop(n).map { |param| param.drop(n) }
  end

  def apply_transform
    @signal = @parameters.map do |param|
      param.zip(@signal).map { |p, s| p * s }.inject(0, :+).abs % 10
    end
  end

  private

  PARAM_VALUES = [0,1,0,-1]

  def calculate_parameters(num_parameters)
    @parameters = []
    (1..num_parameters).each do |index|
      @parameters << (0..num_parameters)
        .map { |n| (n / index) % 4 }
        .drop(1)
        .map { |n| PARAM_VALUES[n] }
    end
  end
end

num_iterations = ARGV.shift.to_i
starting_signal = ARGF.read.strip.chars.map(&:to_i)
fft = FFT.new(starting_signal)
num_iterations.times { fft.apply_transform }
puts fft.signal.take(8).join('')


# Part 2:
# Note that digit n of the output depends only on digits n and farther of the
# input.  In this case, the offset is so large that applying the transform once
# is the same as multiplying by a triangular matrix with ones on and above the
# diagonal and zeros below.

offset = starting_signal.take(7).join('').to_i
puts offset
remaining_length = starting_signal.length * 10000 - offset
puts remaining_length
long_signal =
  (remaining_length / starting_signal.length)
  .times
  .map { starting_signal }
  .inject(starting_signal.drop(offset % starting_signal.length), &:concat)
puts long_signal.length
num_iterations.times do |n|
  (long_signal.length - 2).downto(0) do |i|
    long_signal[i] += long_signal[i+1]
    long_signal[i] %= 10
  end
end
puts long_signal.take(8).join('')

