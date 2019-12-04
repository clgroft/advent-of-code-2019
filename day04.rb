def is_possible_password(num)
  chars = num.to_s.split('')
  adjacent_pairs = chars.each_cons(2).to_a
  # adjacent_pairs = chars[0..-2].zip(chars[1..-1])
  adjacent_pairs.all? { |a, b| a <= b } && adjacent_pairs.any? { |a, b| a == b }
  # adjacent_pairs.all? { |p| p[0] <= p[1] } && adjacent_pairs.any? { |p| p[0] == p[1] }
end

def is_possible_password_2(num)
  return false unless is_possible_password(num)
  chars = num.to_s.split('')
  chunks = chars.chunk { |c| c }
  chunks.any? { |ck| ck[1].length == 2 }
end

bottom_of_range = ARGV[0].to_i
top_of_range = ARGV[1].to_i

possible_passwords = (bottom_of_range..top_of_range).select { |n| is_possible_password(n) }
puts "Number of possible passwords: #{possible_passwords.length}"
possible_passwords_2 = (bottom_of_range..top_of_range).select { |n| is_possible_password_2(n) }
puts "Number of possible passwords (part 2): #{possible_passwords_2.length}"
