input = File.read("./05input.txt").split("\n")

vents = input.map do |line|
  origin, endpoint = line.split(" -> ").map do |point|
    coords = point.split(",").map(&:to_i)
    { x: coords[0], y: coords[1] }
  end
  { from: origin, to: endpoint }
end

lines_crossing = Hash.new { |h, k| h[k] = 0 }

# range ignoring order (normally, 4..1 is an empty range, we want it to return 1..4)
def range(a, b)
  if a > b
    b..a
  else
    a..b
  end
end

vents.each do |vent|
  if vent[:from][:x] == vent[:to][:x]
    x = vent[:from][:x]
    range(vent[:from][:y], vent[:to][:y]).each do |y|
      point = { x: x, y: y }
      lines_crossing[point] += 1
    end
  elsif vent[:from][:y] == vent[:to][:y]
    y = vent[:from][:y]
    range(vent[:from][:x], vent[:to][:x]).each do |x|
      point = { x: x, y: y }
      lines_crossing[point] += 1
    end
  end
end

puts lines_crossing.values.count { |c| c >= 2 }
