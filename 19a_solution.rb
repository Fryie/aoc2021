require 'set'

filename = "test.txt"
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

def matching_dir(perm, sign1, sign2)
  cross_prod(
    unit(perm[0], sign1),
    unit(perm[1], sign2)
  )[perm[2]]
end

$orientations = dirs.flat_map do |e1|
  dirs.flat_map do |e2|
    [0, 1, 2].permutation.map do |perm|
      { perm: perm, dir: [e1, e2, matching_dir(perm, e1, e2)] }
    end
  end
end

def invert(orientation)
  {
    perm: orientation[:perm],
    dir: orientation[:dir].map { |e| -e }
  }
end

def try_overlap(scanners, scanner_data, a_idx, b_idx, size)
  scanner_a = scanners[a_idx]
  scanner_b = scanners[b_idx]

  scanner_b_pos, orientation = try_match(scanner_a, scanner_b, size)
  if !scanner_b_pos.nil?
    scanner_data[b_idx][:paths] << {
      from: a_idx,
      pos: scanner_b_pos
    }
    scanner_data[a_idx][:paths] << {
      from: b_idx,
      pos: scanner_b_pos.map { |e| -e }
    }
    scanner_data[b_idx][:orientation] = orientation
  end
end

def try_match(as, bs, size)
  $orientations.each do |orientation|
    as.each do |first_a|
      bs.each do |first_b|
        opposite = invert(orientation)
        b_pos = move(first_a, first_b, opposite)
        beacons_abs = bs.map { |b| move(b_pos, b, orientation) }

        inter = Set.new(beacons_abs).intersection(Set.new(as))
        if inter.count == size
          return [b_pos, orientation]
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
    try_overlap(scanners, scanner_data, i1, i2, size)
  end

  # fill in missing orientations
  indices.filter { |i| scanner_data[i][:orientation].nil? }.each do |i|
    scanner_data[i][:paths].each do |path|
      scanner_b_pos, orientation = try_match(scanners[path[:from]], scanners[i], size)
      if !scanner_b_pos.nil?
        scanner_data[i][:orientation] = orientation
      end
    end
  end
end

def reduce(scanner_data)
  loop do
    result = reduce_once(scanner_data)
    break if result.nil?

    result[0][:paths] << { from: 0, pos: result[1] }
  end
end

def reduce_once(scanner_data)
  without_zero(scanner_data).each do |sd|
    sd[:paths].each do |path|
      from_data = scanner_data[path[:from]]
      zero_to_from = zero_path(from_data)
      if !zero_to_from.nil?
        new_path = move(
          zero_to_from[:pos],
          path[:pos],
          scanner_data[path[:from]][:orientation]
        )
        return [sd, new_path]
      end
    end
  end

  nil
end

def without_zero(scanner_data)
  scanner_data.filter do |sd|
    zero_path(sd).nil?
  end
end

def zero_path(sd)
  sd[:paths].find do |path|
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

def scanner_positions(scanner_data)
  scanner_data.map do |d|
    p = d[:paths].find do |path|
      path[:from] == 0
    end
    !p.nil? ? p[:pos] : nil
  end
end

def find_beacons(beacons, scanners, scanner_data, scanner_pos)
  scanners.each_with_index do |scanner, i|
    scanner.each do |beacon|
      beacon_abs = move(scanner_pos[i], beacon, scanner_data[i][:orientation])
      beacons.add beacon_abs
    end
  end
end

scanners = parse_input("test.txt")
scanner_data = Array.new(scanners.length) { {paths: [], orientation: nil} }
scanner_data[0] = {
  paths: [{ from: 0, pos: [0,0,0]}],
  orientation: { perm: [0, 1, 2], dir: [1, 1, 1] }
}

overlap_all(scanners, scanner_data, num_beacons)
reduce(scanner_data)
scanner_pos = scanner_positions(scanner_data)
beacons = Set.new
find_beacons(beacons, scanners, scanner_data, scanner_pos)
puts beacons.count
