input = File.read("./01input.txt").split("\n").map(&:to_i)

windows = []
input.each_cons(3) do |slice|
  windows << slice.sum
end

count = 0
windows.each_cons(2) do |slice|
  if slice[1] > slice[0]
    count += 1
  end
end

puts count
