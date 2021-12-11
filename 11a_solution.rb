require 'set'

input = File.read("./11input.txt").split("\n").map do |l|
  l.split("").map(&:to_i)
end

def neighbours(board, ri, ci)
  ns = []
  max_ri = board.length-1
  max_ci = board[ri].length-1

  if ri != 0
    ns << [ri-1,ci]
  end
  if ci != 0
    ns << [ri,ci-1]
  end
  if ri != max_ri
    ns << [ri+1,ci]
  end
  if ci != max_ci
    ns << [ri,ci+1]
  end
  if ri != 0 && ci != 0
    ns << [ri-1,ci-1]
  end
  if ri != 0 && ci != max_ci
    ns << [ri-1,ci+1]
  end
  if ri != max_ri && ci != 0
    ns << [ri+1,ci-1]
  end
  if ri != max_ri && ci != max_ci
    ns << [ri+1,ci+1]
  end

  ns
end

def flash(board, ri, ci, num_flashes, flashed)
  return num_flashes if board[ri][ci] <= 9
  return num_flashes if flashed.include? [ri,ci]

  flashed.add [ri,ci]

  new_num = num_flashes + 1

  neighbours(board, ri, ci).each do |nri, nci|
    board[nri][nci] += 1
    new_num = flash(board, nri, nci, new_num, flashed)
  end

  return new_num
end

num_flashes = 0

100.times do
  flashed = Set.new

  input.each_with_index do |row, ri|
    row.each_with_index do |entry, ci|
      input[ri][ci] += 1
    end
  end

  input.each_with_index do |row, ri|
    row.each_with_index do |entry, ci|
      num_flashes = flash(input, ri, ci, num_flashes, flashed)
    end
  end

  flashed.each do |ri, ci|
    input[ri][ci] = 0
  end
end

puts num_flashes
