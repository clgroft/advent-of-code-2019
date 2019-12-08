# array of layers as strings
layer_strs = File.open("inputs/day08.txt") { |f| f.read.strip.scan(/.{150}/) }

# Part 1
fewest_zeros_layer = layer_strs.min_by { |layer| layer.scan(/0/).size }
checksum = fewest_zeros_layer.scan(/1/).size * fewest_zeros_layer.scan(/2/).size
puts "Checksum: #{checksum}"
puts

layer_strs
  .map(&:chars) # now each layer is an array
  .transpose    # array of length 150, each element is a stack of pixels
  .map { |pixel_arr| pixel_arr.select { |c| c != "2" }.first } # first non-transparent code
  .map { |pixel| pixel == "1" ? "*" : " " } # easier to read
  .each_slice(25) { |row_arr| puts row_arr.join } # print the rows

