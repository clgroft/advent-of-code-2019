module Enumerable
  def sorted?
    each_cons(2).all? { |a, b| (a <=> b) <= 0 }
  end
end

def char_chunks(num)
  num.to_s.split('').chunk { |c| c }
end

def is_possible_password(num)
  chunks = char_chunks(num)
  chunks.sorted? && chunks.any? { |ck| ck[1].size >= 2 }
end

def is_possible_password_2(num)
  chunks = char_chunks(num)
  chunks.sorted? && chunks.any? { |ck| ck[1].size == 2 }
end

bottom_of_range = ARGV[0].to_i
top_of_range = ARGV[1].to_i

possible_passwords = (bottom_of_range..top_of_range).select { |n| is_possible_password(n) }
puts "Number of possible passwords (part 1): #{possible_passwords.size}"

possible_passwords_2 = (bottom_of_range..top_of_range).select { |n| is_possible_password_2(n) }
puts "Number of possible passwords (part 2): #{possible_passwords_2.size}"
