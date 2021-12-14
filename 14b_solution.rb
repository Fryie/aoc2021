input = File.read("14input.txt").split("\n")

polymer = input[0].split("")

rules = input[2..].map do |line|
  parts = line.split(" -> ")
  [parts[0].split(""), parts[1]]
end.to_h

freqs = Hash.new { |h, k| h[k] = 0 }
polymer.each do |c|
  freqs[c] += 1
end

pair_freqs = Hash.new { |h, k| h[k] = 0 }
polymer.each_cons(2) do |pair|
  pair_freqs[pair] += 1
end

num_steps = 40

def step(freqs, pair_freqs, rules)
  new_freqs = freqs.dup
  new_pair_freqs = Hash.new { |h, k| h[k] = 0 }

  pair_freqs.each do |pair, f|
    insertion = rules[pair]
    if insertion.nil?
      new_pair_freqs[pair] += f
    else
      new_freqs[insertion] += f
      new_pair_freqs[[pair[0], insertion]] += f
      new_pair_freqs[[insertion, pair[1]]] += f
    end
  end

  [new_freqs, new_pair_freqs]
end

def count(freqs)
  sorted = freqs.values.sort
  sorted[-1] - sorted[0]
end

num_steps.times do |i|
  freqs, pair_freqs = step(freqs, pair_freqs, rules)
end

puts count(freqs)
