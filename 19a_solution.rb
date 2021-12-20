require 'set'

scanners = [
  [[0,2],[4,1],[3,3]],
  [[-1,-1],[-5,0],[-2,1]]
]

scanner_data = Array.new(scanners.length) { [] }
scanner_data[0] << { from: 0, pos: [0,0], orientation: [1,1] }

$orientations = [-1, 1].flat_map { |e1| [-1, 1].map { |e2| [e1, e2] } }

def subsets(a, size, exclude=Set.new)
  return Set.new([Set.new]) if size == 0

  subsets = Set.new

  a.each_with_index do |e, i|
    unless exclude.include?(i)
      remainders = subsets(a, size-1, exclude + [i])
      remainders.each do |remainder|
        subsets.add(remainder + [e])
      end
    end
  end

  subsets
end

def try_overlap(scanners, scanner_data, a_idx, b_idx, size)
  scanner_a = scanners[a_idx]
  scanner_b = scanners[b_idx]

  subsets(scanner_a, 3).each do |as|
    subsets(scanner_b, 3).each do |bs|
      # relative to a
      scanner_b_pos, orientation = try_match(as, bs)
      if !scanner_b_pos.nil?
        scanner_data[b_idx] << {
          from: a_idx,
          pos: scanner_b_pos,
          orientation: orientation
        }
        scanner_data[a_idx] << {
          from: b_idx,
          pos: scanner_b_pos.map { |e| -e },
          orientation: orientation
        }
        return
      end
    end
  end
end

def try_match(as, bs)
  $orientations.each do |orientation|
    bs.each do |first_b|
      first_a = as.first
      opposite = orientation.map { |e| -e }
      b_pos = move(first_a, first_b, opposite)
      b_abs = bs.map { |b| move(b_pos, b, orientation) }

      if as.sort == b_abs.sort
        return [b_pos, orientation]
      end
    end
  end

  nil
end

def move(a, b, orientation)
  a.each_with_index.map do |e, i|
    e + orientation[i] * b[i]
  end
end

def overlap_all(scanners, scanner_data, size)
  indices = (0...scanners.count)
  index_pairs = indices.flat_map do |i|
    indices.map do |j|
      if i>=j
        nil
      else
        [i, j]
      end
    end.compact
  end

  index_pairs.each do |i1, i2|
    try_overlap(scanners, scanner_data, i1, i2, 3)
  end
end

overlap_all(scanners, scanner_data, 3)
#try_overlap(scanners, scanner_data, 0, 1, 3)
puts scanner_data.inspect
