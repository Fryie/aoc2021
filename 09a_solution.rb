input = File.read("./09input.txt")

board = input.split("\n").map do |line|
  line.split("").map(&:to_i)
end

def is_low_point(board, ri, ci)
  element = board[ri][ci]
  last_ri = board.length - 1
  last_ci = board[ri].length - 1

  if ri != 0 && board[ri-1][ci] <= element
    return false
  end
  if ci != last_ci && board[ri][ci+1] <= element
    return false
  end
  if ri != last_ri && board[ri+1][ci] <= element
    return false
  end
  if ci != 0 && board[ri][ci-1] <= element
    return false
  end

  return true
end

risk_sum = 0

board.each_with_index do |row, ri|
  row.each_with_index do |entry, ci|
    if is_low_point(board, ri, ci)
      risk_sum += entry + 1
    end
  end
end

puts risk_sum
