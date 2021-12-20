require 'set'

filename = "test.txt"
dirs = [1, -1]
num_beacons = 12
$orientations = dirs.flat_map do |e1|
  dirs.flat_map do |e2|
    dirs.map { |e3| [e1, e2, e3] }
  end
end

def try_overlap(scanners, scanner_data, a_idx, b_idx, size)
  scanner_a = scanners[a_idx]
  scanner_b = scanners[b_idx]

  scanner_b_pos, orientation = try_match(scanner_a, scanner_b, size)
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
  end
end

def try_match(as, bs, size)
  $orientations.each do |orientation|
    as.each do |first_a|
      bs.each do |first_b|
        opposite = orientation.map { |e| -e }
        b_pos = move(first_a, first_b, opposite)
        b_abs = bs.map { |b| move(b_pos, b, orientation) }

        inter = Set.new(b_abs).intersection(Set.new(as))
        puts "inter: #{inter.count}" if inter.count > 1
        if inter.count == size
          puts inter.to_a.map { |a| a.join(",") }.join("\n")
          return [b_pos, orientation]
        end
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
    puts "try: #{i1}, #{i2}"
    try_overlap(scanners, scanner_data, i1, i2, size)
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

scanners = parse_input("test.txt")
scanner_data = Array.new(scanners.length) { [] }
scanner_data[0] << { from: 0, pos: [0,0,0], orientation: [1,1,1] }

overlap_all(scanners, scanner_data, num_beacons)
puts scanner_data.inspect
