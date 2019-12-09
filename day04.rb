#!/usr/bin/env ruby

module Enumerable
  def sorted?
    each_cons(2).all? { |a, b| (a <=> b) <= 0 }
  end
end

class Fixnum
  def char_chunks
    to_s.split('').chunk(&:itself)
  end

  def is_possible_password?
    chunks = char_chunks
    chunks.sorted? && chunks.any? { |_, b| b.size >= 2 }
  end

  def is_possible_password_2?
    chunks = char_chunks
    chunks.sorted? && chunks.any? { |_, b| b.size == 2 }
  end
end

bottom_of_range = ARGV[0].to_i
top_of_range = ARGV[1].to_i

possible_passwords = (bottom_of_range..top_of_range).select(&:is_possible_password?)
puts "Number of possible passwords (part 1): #{possible_passwords.size}"

possible_passwords_2 = (bottom_of_range..top_of_range).select(&:is_possible_password_2?)
puts "Number of possible passwords (part 2): #{possible_passwords_2.size}"
