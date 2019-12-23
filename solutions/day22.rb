#!/usr/bin/env ruby


# A shuffle for a deck of size n, where card i is in position ai + b (mod n).
class EfficientShuffle
  attr_reader :n, :a, :b
  def initialize(n, a=1, b=0)
    @n = n
    @a = a
    @b = b
  end

  def reverse
    self.class.new(n, -a % n, (-b-1) % n)
  end

  def cut(k)
    self.class.new(n, a, (b-k) % n)
  end

  def increment(k)
    self.class.new(n, (a*k) % n, (b*k) % n)
  end

  def position_of(c)
    (((a * c) % n) + b) % n
  end

  def card_at(i)
    (((i - b) % n) * a_inverse) % n
  end

  def pow(p)
    result = self.class.new(n)
    repeated_square = self
    while p > 0
      result = result.compose(repeated_square) if p % 2 == 1
      p /= 2
      repeated_square = repeated_square.square
    end
    result
  end

  def square
    compose(self)
  end

  # The result of performing other followed by self.
  def compose(other)
    self.class.new(n, a * other.a % n, (((a * other.b) % n) + b) % n)
  end

  private

  def a_inverse
    inverse(a)
  end

  def inverse(k)
    _i, j = extended_gcd_coefficients(n, k)
    j % n
  end

  # Returns [i, j] where ir + js = gcd(r, s)
  # Assumes r > s >= 0
  def extended_gcd_coefficients(r, s)
    return [1, 0] if s == 0
    quotient, remainder = r.divmod(s) # r = quotient * s + remainder
    i, j = extended_gcd_coefficients(s, remainder)
    [j, i-(quotient * j)]
  end
end


base_shuffle_1 = EfficientShuffle.new(10007)
base_shuffle_2 = EfficientShuffle.new(119315717514047)
ARGF.each_line.map(&:strip).each do |line|
  case line
  when 'deal into new stack'
    base_shuffle_1 = base_shuffle_1.reverse
    base_shuffle_2 = base_shuffle_2.reverse
  when /deal with increment (.+)/
    k = Regexp.last_match[1].to_i
    base_shuffle_1 = base_shuffle_1.increment(k)
    base_shuffle_2 = base_shuffle_2.increment(k)
  when /cut (.+)/
    k = Regexp.last_match[1].to_i
    base_shuffle_1 = base_shuffle_1.cut(k)
    base_shuffle_2 = base_shuffle_2.cut(k)
  end
end

puts "Part 1: card 2019 is at #{base_shuffle_1.position_of(2019)}"

full_shuffle_2 = base_shuffle_2.pow(101741582076661)

puts "Part 2: position 2020 has card #{full_shuffle_2.card_at(2020)}"

