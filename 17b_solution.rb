require 'set'

# easier to hardcode the input than to parse it from a file in this case
target = { min_x: 56, max_x: 76, min_y: -162, max_y: -134 }

def all_solutions(target)
  solutions = Set.new

  (target[:min_y]..-target[:min_y]-1).each do |y|
    ns = if y > 0
           possible_ns(-y-1, target, true)
         else
           possible_ns(y, target, false)
         end

    ns.each do |n|
      # we have target[:min_x]/n <= x <= target[:max_x]
      lower_bound = (target[:min_x]/n.to_f).ceil

      (lower_bound..target[:max_x]).each do |x|
        if valid_x?(x, n, target)
          solutions.add [x, y]
        end
      end
    end
  end

  solutions
end

def possible_ns(y, target, up_first)
  ns = []
  current_y = y
  current_height = 0

  # count steps from the point we're going down
  # (ignoring any possible upwards movement before)
  1.step do |n|
    current_height += current_y
    current_y -= 1
    if current_height < target[:min_y] # we overshot
      break
    elsif current_height <= target[:max_y] # we're in vertical range
      # if we go up first, always the number of steps to get to highest point and back
      ns << (up_first ? 2*(-y-1) + 1 + n : n)
    end
  end

  ns
end

def valid_x?(x, n, target)
  current_x = x
  current_pos = 0

  n.times do
    current_pos += current_x
    if current_x > 0
      current_x -= 1
    end
  end

  current_pos >= target[:min_x] && current_pos <= target[:max_x]
end

puts all_solutions(target).count
