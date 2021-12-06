input = File.read("./03input.txt").split("\n").map { |line| line.split("").map(&:to_i) }

width = input[0].length
range = 0..(width-1)

def reduce(input, pos)
  output = []

  no0 = 0
  no1 = 0

  input.each do |line|
    if line[pos] == 0
      no0 += 1
    else
      no1 += 1
    end
  end

  input.each do |line|
    yield output, line, pos, no0, no1
  end

  output
end

oxygen = input

range.each do |pos|
  break if oxygen.count == 1

  oxygen = reduce(oxygen, pos) do |output, line, pos, no0, no1|
    if no0 == no1
      if line[pos] == 1
        output << line
      end
    elsif no0 > no1
      if line[pos] == 0
        output << line
      end
    else
      if line[pos] == 1
        output << line
      end
    end
  end
end

oxygen_int = oxygen.join("").to_i(2)

co2 = input

range.each do |pos|
  break if co2.count == 1

  co2 = reduce(co2, pos) do |output, line, pos, no0, no1|
    if no0 == no1
      if line[pos] == 0
        output << line
      end
    elsif no0 > no1
      if line[pos] == 1
        output << line
      end
    else
      if line[pos] == 0
        output << line
      end
    end
  end
end

co2_int = co2.join("").to_i(2)

puts oxygen_int * co2_int
