require 'set'

input = File.read("./13input.txt")

dot_input, fold_input = input.split("\n\n")

dots = Set.new
max_x, max_y = [0, 0]

dot_input.split("\n").each do |line|
  x, y = line.split(",").map(&:to_i)
  if x > max_x
    max_x = x
  end
  if y > max_y
    max_y = y
  end
  dots.add [x, y]
end

folds = []

fold_input.split("\n").each do |line|
  match = /fold along (.)=(\d+)/.match line
  folds << [match[1].to_sym, match[2].to_i]
end

def draw(dots, max_x, max_y)
  puts "\n--------------------\n"
  (0..max_y).each do |y|
    line = (0..max_x).map do |x|
      dots.include?([x, y]) ? '#' : '.'
    end
    puts line.join("")
  end
end

# returns new [max_x, max_y]
def do_fold(fold, dots, max_x, max_y)
  new_max_x = fold[0] == :x ? fold[1] - 1 : max_x
  new_max_y = fold[0] == :y ? fold[1] - 1 : max_y

  if fold[0] == :x
    ((fold[1]+1)..max_x).each do |x|
      (0..max_y).each do |y|
        if dots.include? [x, y]
          new_x = 2*fold[1] - x
          dots.add [new_x, y]
        end
      end
    end
  else
    (0..max_x).each do |x|
      ((fold[1]+1)..max_y).each do |y|
        if dots.include? [x, y]
          new_y = 2*fold[1] - y
          dots.add [x, new_y]
        end
      end
    end
  end

  [new_max_x, new_max_y]
end

def count_dots(dots, max_x, max_y)
  dots.count { |dot| dot[0] <= max_x && dot[1] <= max_y }
end

folds.each do |fold|
  max_x, max_y = do_fold(fold, dots, max_x, max_y)
end

draw(dots, max_x, max_y)
