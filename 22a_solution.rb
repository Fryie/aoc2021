filename = "22input.txt"

$digit_pattern = "(-?\\d+)"
$digit_pair_pattern = "#{$digit_pattern}..#{$digit_pattern}"

def parse_int(str)
  if str[0] == '-'
    -str[1..].to_i
  else
    str.to_i
  end
end

def parse_input(filename)
  lines = File.read(filename).split("\n")
  lines.map do |line|
    match = /(on|off) x=#{$digit_pair_pattern},y=#{$digit_pair_pattern},z=#{$digit_pair_pattern}/.match(line)
    type = match[1].to_sym
    {
      type: type,
      x_from: parse_int(match[2]),
      x_to: parse_int(match[3]),
      y_from: parse_int(match[4]),
      y_to: parse_int(match[5]),
      z_from: parse_int(match[6]),
      z_to: parse_int(match[7]),
    }
  end.reverse
end

def in_bounds?(cuboid, x, y, z)
  x >= cuboid[:x_from] &&
    x <= cuboid[:x_to] &&
    y >= cuboid[:y_from] &&
    y <= cuboid[:y_to] &&
    z >= cuboid[:z_from] &&
    z <= cuboid[:z_to]
end

def last_cuboid(cuboids, x, y, z)
  # assume cuboids are reverse ordered
  cuboids.find { |cuboid| in_bounds?(cuboid, x, y, z) }
end

def get_count(cuboids)
  count = 0

  (-50..50).each do |x|
    (-50..50).each do |y|
      (-50..50).each do |z|
        last = last_cuboid(cuboids, x, y, z)
        if !last.nil? && last[:type] == :on
          count += 1
        end
      end
    end
  end

  count
end

cuboids = parse_input(filename)
puts get_count(cuboids)
