# easier to hardcode the input than to parse it from a file in this case
target = { min_x: 56, max_x: 76, min_y: -162, max_y: -134 }

# this code only works when it assumes that the target is to the right of the origin
# and below the x axis. The first assumption could be relaxed with tedious extra
# conditions, but the second assumption is integral to this algorithm...

def max_height(target)
  _, y, n = max_by_y(target)
  return 0 if y <= 0

  current_y = y
  current_height = 0

  n.times do
    current_height += current_y

    current_y -= 1
    if current_y == 0
      break
    end
  end

  current_height
end

def max_by_y(target)
  # start with largest possible value (other values will overshoot)
  # and try until a value is found that works.
  (0..-target[:min_y]-1).to_a.reverse.each do |y|
    ns = possible_ns(y, target)

    ns.each do |n|
      # we have target[:min_x]/n <= x <= target[:max_x]
      lower_bound = (target[:min_x]/n.to_f).ceil

      (lower_bound..target[:max_x]).each do |x|
        if valid_x?(x, n, target)
          return [x, y, n]
        end
      end
    end
  end

  # it's always at least 0
  0
end

def possible_ns(y, target)
  ns = []
  current_height = 0

  # count steps from the point we're back at y=0
  1.step do |n|
    current_height -= y+n
    if current_height < target[:min_y] # we overshot
      break
    elsif current_height <= target[:max_y] # we're in vertical range
      # always add 2y+1 steps to get to highest point and back
      ns << 2*y + 1 + n
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

puts max_height(target)
