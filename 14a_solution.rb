input = File.read("14input.txt").split("\n")

polymer = input[0].split("")

rules = input[2..].map do |line|
  parts = line.split(" -> ")
  [parts[0].split(""), parts[1]]
end.to_h

num_steps = 10

def step(polymer, rules)
  polymer.each_cons(2).flat_map do |pair|
    insertion = rules[pair]
    if insertion.nil?
      pair[0]
    else
      [pair[0], insertion]
    end
  end + [polymer[-1]]
end

def count(polymer)
  freqs = Hash.new { |h, k| h[k] = 0 }
  polymer.each do |c|
    freqs[c] += 1
  end

  most_common = nil
  max = nil
  least_common = nil
  min = nil

  freqs.keys.each do |k|
    if most_common.nil? || freqs[k] > max
      most_common = k
      max = freqs[k]
    end
    if least_common.nil? || freqs[k] < min
      least_common = k
      min = freqs[k]
    end
  end

  max - min
end

num_steps.times do
  polymer = step(polymer, rules)
end

puts count(polymer)
