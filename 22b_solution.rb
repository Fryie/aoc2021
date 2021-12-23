require 'set'

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
      bounds: {
        x_from: parse_int(match[2]),
        x_to: parse_int(match[3]),
        y_from: parse_int(match[4]),
        y_to: parse_int(match[5]),
        z_from: parse_int(match[6]),
        z_to: parse_int(match[7])
      }
    }
  end
end

def overlap?(c1, c2)
  c2[:x_from] <= c1[:x_to] &&
    c2[:x_to] >= c1[:x_from] &&
    c2[:y_from] <= c1[:y_to] &&
    c2[:y_to] >= c1[:y_from] &&
    c2[:z_from] <= c1[:z_to] &&
    c2[:z_to] >= c1[:z_from]
end

# split the union A & B into disjoint cuboids
def disjoint_union(a, b)
  diff(a, b) + [b]
end

# create a disjoint union of {A_i} & B, where the {A_i} are disjoint
def disjoint_union_all(as, b)
  return Set.new([b]) if as.empty?

  as_a = as.to_a

  sets = disjoint_union(as_a[0], b).to_a + as_a.drop(1).flat_map do |a|
    diff(a, b).to_a
  end

  Set.new(sets)
end

# split the difference A\B into disjoint cuboids
def diff(a, b)
  return nil if a.nil?
  return Set.new([a]) if b.nil?
  return Set.new([a]) if !overlap?(a, b)

  disjoint = Set.new

  remaining_bounds = a.dup

  if remaining_bounds[:x_to] > b[:x_to]
    disjoint.add remaining_bounds.merge(x_from: b[:x_to]+1)
    remaining_bounds[:x_to] = b[:x_to]
  end
  if remaining_bounds[:y_to] > b[:y_to]
    disjoint.add remaining_bounds.merge(y_from: b[:y_to]+1)
    remaining_bounds[:y_to] = b[:y_to]
  end
  if remaining_bounds[:z_to] > b[:z_to]
    disjoint.add remaining_bounds.merge(z_from: b[:z_to]+1)
    remaining_bounds[:z_to] = b[:z_to]
  end

  if remaining_bounds[:x_from] < b[:x_from]
    disjoint.add remaining_bounds.merge(x_to: b[:x_from]-1)
    remaining_bounds[:x_from] = b[:x_from]
  end
  if remaining_bounds[:y_from] < b[:y_from]
    disjoint.add remaining_bounds.merge(y_to: b[:y_from]-1)
    remaining_bounds[:y_from] = b[:y_from]
  end
  if remaining_bounds[:z_from] < b[:z_from]
    disjoint.add remaining_bounds.merge(z_to: b[:z_from]-1)
    remaining_bounds[:z_from] = b[:z_from]
  end

  disjoint
end

def points_in(cuboid)
  return 0 if cuboid.nil?

  (cuboid[:x_to]-cuboid[:x_from]+1) *
    (cuboid[:y_to]-cuboid[:y_from]+1) *
    (cuboid[:z_to] - cuboid[:z_from]+1)
end

def process(cuboids)
  union = Set.new

  cuboids.each do |c|
    current_set = c[:bounds]

    if c[:type] == :on
      union = disjoint_union_all(union, current_set)
    else
      new_sets = union.flat_map { |previous_set| diff(previous_set, current_set).to_a }
      union = Set.new(new_sets)
    end
  end

  union
end

def total_points(disjoint_union)
  disjoint_union.inject(0) do |a, set|
    a + points_in(set)
  end
end

cuboids = parse_input(filename)
disjoint_union = process(cuboids)
puts total_points(disjoint_union)
