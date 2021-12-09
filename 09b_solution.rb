require 'set'

input = File.read("./09input.txt")

board = input.split("\n").map do |line|
  line.split("").map(&:to_i)
end

def neighbours(board, ri, ci)
  result = []

  last_ri = board.length - 1
  last_ci = board[ri].length - 1

  if ri != 0
    result << [ri-1, ci]
  end
  if ri != last_ri
    result << [ri+1, ci]
  end
  if ci != 0
    result << [ri, ci-1]
  end
  if ci != last_ci
    result << [ri, ci+1]
  end

  result
end

def is_low_point(board, ri, ci)
  element = board[ri][ci]

  neighbours(board, ri, ci).all? do |nri, nci|
    element < board[nri][nci]
  end
end

def basin_size(board, ri, ci, visited = Set.new)
  return 0 if visited.include? [ri,ci]
  visited.add [ri, ci]

  basin_neighbours = neighbours(board, ri, ci).lazy.select do |nri, nci|
    n = board[nri][nci]
    n != 9 && board[ri][ci] < n
  end

  1 + basin_neighbours.inject(0) do |a, (nri, nci)|
    a + basin_size(board, nri, nci, visited)
  end
end

basin_sizes = []

board.each_with_index do |row, ri|
  row.each_with_index do |entry, ci|
    if is_low_point(board, ri, ci)
      basin_sizes << basin_size(board, ri, ci)
    end
  end
end

# definitely not the most efficient solution, but I'm lazy
largest_sizes = basin_sizes.sort.reverse.take(3)
result = largest_sizes.inject(1) { |a, e| a * e }

puts result
