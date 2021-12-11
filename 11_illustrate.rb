require 'set'

input = File.read("./11input.txt").split("\n").map do |l|
  l.split("").map(&:to_i)
end

ESC = "\033["

def clear(board)
  $stdout.write "#{ESC}#{board.count+1}A"
  board[0].each do
    $stdout.write "\b"
  end
end

def print_num(board, ri, ci, flashed)
  adjusted = board[ri][ci].to_s.ljust(3)
  if flashed.include? [ri, ci]
    "#{ESC}32m#{adjusted}#{ESC}0m"
  else
    adjusted
  end
end

def print_board(board, step, flashed, do_clear=true)
  sleep 0.05
  if do_clear
    clear(board)
  end
  puts "step #{step}:"
  board.each_with_index do |row, ri|
    line = row.each_with_index.map do |_, ci|
      print_num(board, ri, ci, flashed)
    end.join(" ")
    puts line
  end
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

def flash(board, ri, ci, flashed, step)
  return if board[ri][ci] <= 9
  return if flashed.include? [ri,ci]

  flashed.add [ri,ci]

  neighbours(board, ri, ci).each do |nri, nci|
    board[nri][nci] += 1
    flash(board, nri, nci, flashed, step)
  end

  print_board(board, step, flashed)
end

print_board(input, 0, Set.new, false)

100.times do |step|
  flashed = Set.new

  input.each_with_index do |row, ri|
    row.each_with_index do |entry, ci|
      input[ri][ci] += 1
    end
  end

  input.each_with_index do |row, ri|
    row.each_with_index do |entry, ci|
      flash(input, ri, ci, flashed, step)
    end
  end

  flashed.each do |ri, ci|
    input[ri][ci] = 0
  end

  print_board(input, step+1, flashed)
end
