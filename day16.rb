#!/usr/bin/env ruby


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

# long_starting_signal = 10000.times.map { starting_signal }.inject(&:concat)
# long_fft = FFT.new(long_starting_signal)
# offset = starting_signal.take(7).join('').to_i
# long_fft.drop(offset)
# num_iterations.times do |n|
#   long_fft.apply_transform
#   puts n
# end
# # num_iterations.times { long_fft.apply_transform }
# puts long_fft.signal.take(8).join('')
#
