def parse_input(input)
  num_match = /^(\d+)/.match(input)
  if !num_match.nil?
    num = num_match[1]
    [num.to_i, num.length]
  else
    first, first_length = parse_input(input[1..])
    second, second_length = parse_input(input[2+first_length..])
    [[first, second], 3+first_length+second_length]
  end
end

def get(a, idx)
  idx.inject(a) do |acc, i|
    acc[i]
  end
end

def set(a, idx, value)
  outer = get(a, idx[0..-2])
  outer[idx.last] = value
end

def lt(idx1, idx2)
  idx1.zip(idx2).each do |i1, i2|
    return false if i1.nil? || i2.nil? # not comparable
    return true if i1 < i2
    return false if i1 > i2
  end

  false
end

def gt(idx1, idx2)
  idx1.zip(idx2).each do |i1, i2|
    return false if i1.nil? || i2.nil? # not comparable
    return true if i1 > i2
    return false if i1 < i2
  end

  false
end

def first(a, idx, &pred)
  first_idx = idx + [0]
  second_idx = idx + [1]

  result_idx = nil

  if pred.call(first_idx)
    result_idx = first_idx
  end
  if result_idx.nil? && get(a, first_idx).is_a?(Array)
    result_idx = first(a, first_idx, &pred)
  end
  if result_idx.nil? && pred.call(second_idx)
    result_idx = second_idx
  end
  if result_idx.nil? && get(a, second_idx).is_a?(Array)
    result_idx = first(a, second_idx, &pred)
  end

  result_idx
end

def last(a, idx, &pred)
  first_idx = idx + [0]
  second_idx = idx + [1]

  result_idx = nil

  if get(a, second_idx).is_a?(Array)
    result_idx = last(a, second_idx, &pred)
  end
  if result_idx.nil? && pred.call(second_idx)
    result_idx = second_idx
  end
  if result_idx.nil? && get(a, first_idx).is_a?(Array)
    result_idx = last(a, first_idx, &pred)
  end
  if result_idx.nil? && pred.call(first_idx)
    result_idx = first_idx
  end

  result_idx
end

def explode(a)
  pair_idx = first(a, []) do |idx|
    idx.count >= 4 && get(a, idx).is_a?(Array)
  end

  return false if pair_idx.nil?

  pair = get(a, pair_idx)

  left_idx = last(a, []) do |idx|
    lt(idx, pair_idx) && !get(a, idx).is_a?(Array)
  end

  if !left_idx.nil?
    old_val = get(a, left_idx)
    set(a, left_idx, old_val + pair[0])
  end

  right_idx = first(a, []) do |idx|
    gt(idx, pair_idx) && !get(a, idx).is_a?(Array)
  end

  if !right_idx.nil?
    old_val = get(a, right_idx)
    set(a, right_idx, old_val + pair[1])
  end

  set(a, pair_idx, 0)

  true
end

def split(a)
  split_idx = first(a, []) do |idx|
    val = get(a, idx)
    !val.is_a?(Array) && val >= 10
  end

  return false if split_idx.nil?

  split_val = get(a, split_idx)
  lower = (split_val/2.0).floor
  upper = (split_val/2.0).ceil

  set(a, split_idx, [lower, upper])

  true
end

def reduce(a)
  done = false
  while !done
    exploded = explode(a)
    if !exploded
      splitted = split(a)
      if !splitted
        done = true
      end
    end
  end
end

def add(a, b)
  # create copy so as not to modify input
  sum = Marshal.load(Marshal.dump([a, b]))
  reduce(sum)
  sum
end

def magnitude(a)
  if a.is_a?(Array)
    3*magnitude(a[0])+2*magnitude(a[1])
  else
    a
  end
end

def max_sum(inputs)
  max = 0

  inputs.each do |a|
    inputs.each do |b|
      if a != b
        this_magnitude = magnitude(add(a, b))
        max = this_magnitude if this_magnitude > max
      end
    end
  end

  max
end

inputs = File.read("18input.txt").split("\n").map { |l| parse_input(l)[0] }
puts max_sum(inputs)
