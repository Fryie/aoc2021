input = File.read("./07input.txt").split(",").map(&:to_i)

min = input.min
max = input.max

min_distance = nil

(min..max).each do |pos|
  cumulative_distance = input.inject(0) do |a, e|
    a + (e-pos).abs
  end

  if min_distance.nil? || cumulative_distance < min_distance
    min_distance = cumulative_distance
  end
end

puts min_distance
