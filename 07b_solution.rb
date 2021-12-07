def fuel_consumption(start, endpoint)
  distance = (start-endpoint).abs

  # consumption is 1+...+distance, which has a nice closed formula
  (distance * (distance + 1))/2
end

input = File.read("./07input.txt").split(",").map(&:to_i)

min = input.min
max = input.max

min_distance = nil

(min..max).each do |pos|
  cumulative_distance = input.inject(0) do |a, e|
    a + fuel_consumption(e, pos)
  end

  if min_distance.nil? || cumulative_distance < min_distance
    min_distance = cumulative_distance
  end
end

puts min_distance
