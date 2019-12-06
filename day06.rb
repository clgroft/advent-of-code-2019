$direct_orbits = Hash.new { |h, k| h[k] = [] }
orbit_com = {}
ARGF.each_line do |line|
  center, orbiting = line.strip.split(')')
  $direct_orbits[center].push(orbiting)
  orbit_com[orbiting] = center
end

$total_orbits = 0
def dfs(center, tail_length)
  $total_orbits += tail_length
  # puts "Total orbits at #{center}: #{$total_orbits}"

  # Avoid making lots of extraneous arrays
  if $direct_orbits.has_key?(center)
    orbiting_objects = $direct_orbits[center]
    # puts "#{center} => #{orbiting_objects}"
    orbiting_objects.each { |object| dfs(object, tail_length + 1) }
  end
end
dfs("COM", 0)
puts "Total number of orbits: #{$total_orbits}"

you_orbits = {}
curr_object = orbit_com["YOU"]
steps = 0
while curr_object
  you_orbits[curr_object] = steps
  curr_object = orbit_com[curr_object]
  steps += 1
end

curr_object = orbit_com["SAN"]
steps = 0
loop do
  if you_orbits.has_key?(curr_object)
    puts "Total steps: #{steps + you_orbits[curr_object]}"
    break
  end
  curr_object = orbit_com[curr_object]
  steps += 1
end

