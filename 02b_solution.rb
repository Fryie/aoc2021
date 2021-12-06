input = File.read("./02input.txt").split("\n")

horizontal = 0
depth = 0
aim = 0

input.each do |line|
  match_forward = /forward (\d+)/.match(line)
  if !match_forward.nil?
    increase = match_forward[1].to_i
    horizontal += increase
    depth += aim * increase
  end
  match_down = /down (\d+)/.match(line)
  if !match_down.nil?
    aim += match_down[1].to_i
  end
  match_up = /up (\d+)/.match(line)
  if !match_up.nil?
    aim -= match_up[1].to_i
  end
end

puts horizontal * depth
