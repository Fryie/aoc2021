require 'set'

filename = "test.txt"
dirs = [1, -1]
num_beacons = 12
$orientations = dirs.flat_map do |e1|
  dirs.flat_map do |e2|
    dirs.flat_map do |e3|
      [:x, :y, :z].map do |f|
        { first: f, dir: [e1, e2, e3] }
      end
    end
  end
end

def invert(orientation)
  {
    first: orientation[:first],
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

  nil
end

def move(a, b, orientation)
  shuffled = case orientation[:first]
             when :x
               a
             when :y
               [a[1], a[2], a[0]]
             else
               [a[2], a[0], a[1]]
             end

  shifted = shuffled.each_with_index.map do |e, i|
    e + orientation[:dir][i] * b[i]
  end

  case orientation[:first]
  when :x
    shifted
  when :y
    [shifted[2], shifted[0], shifted[1]]
  else
    [shifted[1], shifted[2], shifted[0]]
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
    try_overlap(scanners, scanner_data, i1, i2, size)
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

scanners = parse_input("test.txt")
scanner_data = Array.new(scanners.length) { {paths: [], orientation: nil} }
scanner_data[0] = {
  paths: [{ from: 0, pos: [0,0,0]}],
  orientation: { first: :x, dir: [1, 1, 1] }
}

overlap_all(scanners, scanner_data, num_beacons)
reduce(scanner_data)
scanner_pos = scanner_positions(scanner_data)
puts scanner_pos.inspect
