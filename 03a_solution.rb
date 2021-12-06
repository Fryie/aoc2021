input = File.read("./03input.txt").split("\n").map { |line| line.split("").map(&:to_i) }

width = input[0].length
range = 0..(width-1)

number_of_zeroes = range.map { 0 }
number_of_ones = range.map { 0 }

input.each do |line|
  range.each do |pos|
    if line[pos] == 0
      number_of_zeroes[pos] += 1
    else
      number_of_ones[pos] += 1
    end
  end
end

gamma = []
epsilon = []

range.each do |pos|
  if number_of_zeroes[pos] > number_of_ones[pos]
    gamma << 0
    epsilon << 1
  else
    gamma << 1
    epsilon << 0
  end
end

gamma_int = gamma.join("").to_i(2)
epsilon_int = epsilon.join("").to_i(2)

puts gamma_int * epsilon_int
