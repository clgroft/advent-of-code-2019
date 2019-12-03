wire1 = gets.strip.split(",")
wire2 = gets.strip.split(",")

wire_codes = Hash.new { |h,k| h[k] = 0 }
wire1_distance = {}
wire2_distance = {}

x, y = 0, 0
distance_so_far = 0
wire1.each do |code|
  direction, distance = code[0], code[1..-1].to_i
  distance.times do
    case direction
    when "U"
      y += 1
    when "D"
      y -= 1
    when "L"
      x -= 1
    when "R"
      x += 1
    end

    wire_codes[[x, y]] |= 1
    distance_so_far += 1
    wire1_distance[[x, y]] ||= distance_so_far
  end
end

x, y = 0, 0
distance_so_far = 0
wire2.each do |code|
  direction, distance = code[0], code[1..-1].to_i
  distance.times do
    case direction
    when "U"
      y += 1
    when "D"
      y -= 1
    when "L"
      x -= 1
    when "R"
      x += 1
    end

    wire_codes[[x, y]] |= 2
    distance_so_far += 1
    wire2_distance[[x, y]] ||= distance_so_far
  end
end

shortest_distance = wire_codes.keys
  .select { |k| wire_codes[k] == 3 }
  .collect { |k| wire1_distance[k] + wire2_distance[k] } # .collect { |k| k.map(&:abs).reduce(0, :+) }
  .min
print shortest_distance, "\n"
