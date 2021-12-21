require 'set'

filename = "19input.txt"
num_beacons = 12
dirs = [1, -1]

def unit(i, sign)
  [0, 1, 2].map do |j|
    j == i ? sign : 0
  end
end

def cross_prod(a, b)
  [
    a[1]*b[2]-a[2]*b[1],
    a[2]*b[0]-a[0]*b[2],
    a[0]*b[1]-a[1]*b[0]
  ]
end

def right_handed_dir(perm, sign1, sign2)
  cross_prod(
    unit(perm[0], sign1),
    unit(perm[1], sign2)
  )[perm[2]]
end

$orientations = dirs.flat_map do |e1|
  dirs.flat_map do |e2|
    [0, 1, 2].permutation.map do |perm|
      { perm: perm, dir: [e1, e2, right_handed_dir(perm, e1, e2)] }
    end
  end
end

default_orientation = { perm: [0, 1, 2], dir: [1, 1, 1] }

def opposite_orientation(orientation)
  {
    perm: orientation[:perm],
    dir: orientation[:dir].map { |e| -e }
  }
end

def invert(orientation)
  perm = orientation[:perm]
  dir = orientation[:dir]
  inverse_perm = [perm.index(0), perm.index(1), perm.index(2)]

  {
    perm: inverse_perm,
    dir: [dir[inverse_perm[0]], dir[inverse_perm[1]], dir[inverse_perm[2]]]
  }
end

def compose(o1, o2)
  {
    perm: [
      o1[:perm][o2[:perm][0]],
      o1[:perm][o2[:perm][1]],
      o1[:perm][o2[:perm][2]]
    ],
    dir: [
      o2[:dir][0] * o1[:dir][o2[:perm][0]],
      o2[:dir][1] * o1[:dir][o2[:perm][1]],
      o2[:dir][2] * o1[:dir][o2[:perm][2]]
    ]
  }
end

def apply(orientation, point)
  perm = orientation[:perm]
  dir = orientation[:dir]

  [point[perm[0]] * dir[0], point[perm[1]] * dir[1], point[perm[2]] * dir[2]]
end

def try_overlap(scanners, paths, a_idx, b_idx, size)
  scanner_a = scanners[a_idx]
  scanner_b = scanners[b_idx]

  scanner_b_pos, scanner_b_orientation = try_match(scanner_a, scanner_b, size)
  if !scanner_b_pos.nil?
    paths[b_idx] << {
      from: a_idx,
      pos: scanner_b_pos,
      orientation: scanner_b_orientation
    }
    inverted_pos = scanner_b_pos.map { |e| -e }
    paths[a_idx] << {
      from: b_idx,
      pos: apply(invert(scanner_b_orientation), inverted_pos),
      orientation: invert(scanner_b_orientation)
    }
  end
end

def try_match(a_beacons, b_beacons, size)
  $orientations.each do |orientation|
    a_beacons.each do |first_a|
      b_beacons.each do |first_b|
        opposite = opposite_orientation(orientation)
        b_pos_from_a = move(first_a, first_b, opposite)
        b_beacons_from_a = b_beacons
          .map { |b| move(b_pos_from_a, b, orientation) }
          .filter { |b| b.all? { |pos| pos.abs <= 1000 } }

        inter = Set.new(b_beacons_from_a).intersection(Set.new(a_beacons))
        if inter.count >= size
          return [b_pos_from_a, orientation]
        end
      end
    end
  end

  [nil, nil]
end

def move(a, b, orientation)
  perm = orientation[:perm]

  shuffled = [a[perm[0]], a[perm[1]], a[perm[2]]]

  shifted = shuffled.each_with_index.map do |e, i|
    e + orientation[:dir][i] * b[i]
  end

  [shifted[perm.index(0)], shifted[perm.index(1)], shifted[perm.index(2)]]
end

def overlap_all(scanners, paths, size)
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
    puts "try overlapping #{i1} and #{i2}"
    try_overlap(scanners, paths, i1, i2, size)
  end
end

def reduce(scanner_data)
  loop do
    result = reduce_once(scanner_data)
    break if result.nil?

    result[0] << { from: 0, pos: result[1], orientation: result[2] }
  end
end

def reduce_once(paths)
  without_zero(paths).each do |target_paths|
    target_paths.each do |end_path|
      from_data = paths[end_path[:from]]
      zero_to_from = zero_path(from_data)
      if !zero_to_from.nil?
        new_path = move(
          zero_to_from[:pos],
          end_path[:pos],
          zero_to_from[:orientation]
        )
        new_orientation = compose(zero_to_from[:orientation], end_path[:orientation])
        return [target_paths, new_path, new_orientation]
      end
    end
  end

  nil
end

def without_zero(all_paths)
  all_paths.filter do |paths|
    zero_path(paths).nil?
  end
end

def zero_path(paths)
  paths.find do |path|
    path[:from] == 0
  end
end

def parse_input(filename)
  parts = File.read(filename).split("\n\n")
  parts.map do |part|
    part.split("\n")[1..].map do |line|
      line.split(",").map(&:to_i)
    end
  end
end

def scanner_positions(all_paths)
  all_paths.map do |paths|
    p = paths.find do |path|
      path[:from] == 0
    end
    !p.nil? ? p[:pos] : nil
  end
end

def find_beacons(beacons, scanners, paths, scanner_pos)
  scanners.each_with_index do |scanner, i|
    scanner.each do |beacon|
      orientation = zero_path(paths[i])[:orientation]
      beacon_abs = move(scanner_pos[i], beacon, orientation)
      beacons.add beacon_abs
    end
  end
end

scanners = parse_input(filename)
paths = Array.new(scanners.length) { [] }
paths[0] = [
  {
    from: 0,
    pos: [0,0,0],
    orientation: default_orientation
  }
]

overlap_all(scanners, paths, num_beacons)
reduce(paths)
scanner_pos = scanner_positions(paths)
beacons = Set.new
find_beacons(beacons, scanners, paths, scanner_pos)
puts beacons.count
