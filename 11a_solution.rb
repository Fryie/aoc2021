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

def flash(board, ri, ci, flashed)
  return if board[ri][ci] <= 9
  return if flashed.include? [ri,ci]

  flashed.add [ri,ci]

  neighbours(board, ri, ci).each do |nri, nci|
    board[nri][nci] += 1
    flash(board, nri, nci, flashed)
  end
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
      flash(input, ri, ci, flashed)
    end
  end

  flashed.each do |ri, ci|
    input[ri][ci] = 0
  end

  num_flashes += flashed.count
end

puts num_flashes
