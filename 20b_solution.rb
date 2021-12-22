require 'set'

filename = "20input.txt"
num_steps = 50

def parse_input(filename)
  sections = File.read(filename).split("\n\n")

  enhancement = sections[0]
    .split("")
    # just in case the input was wrapped
    .reject { |c| c != '#' && c != '.' }
    .map { |c| c == '#' ? 1 : 0 }

  image_template = sections[1].split("\n").map do |l|
    l.split("").map { |c| c == '#' ? 1 : 0 }
  end

  bounds = {
    x_from: 0,
    x_to: image_template.count-1,
    y_from: 0,
    y_to: image_template[0].count-1
  }

  lights = Set.new

  image_template.each_with_index do |l, i|
    l.each_with_index do |bit, j|
      lights.add [i, j] if bit == 1
    end
  end

  [enhancement, bounds, lights]
end

def step(enhancement, bounds, lights, default)
  new_lights = Set.new
  new_darks = Set.new

  (bounds[:x_from]-2..bounds[:x_to]+2).each do |i|
    (bounds[:y_from]-2..bounds[:y_to]+2).each do |j|
      val = get_value(enhancement, lights, i, j, default, bounds)
      if val == 1
        new_lights.add [i, j]
      else
        new_darks.add [i, j]
      end
    end
  end

  new_bounds = {
    x_from: bounds[:x_from]-2,
    x_to: bounds[:x_to]+2,
    y_from: bounds[:y_from]-2,
    y_to: bounds[:y_to]+2
  }

  [new_bounds, lights.union(new_lights).difference(new_darks)]
end

def get_value(enhancement, lights, i, j, default, bounds)
  neighbours = [
    [i-1,j-1],[i-1,j],[i-1,j+1],
    [i,j-1],[i,j],[i,j+1],
    [i+1,j-1],[i+1,j],[i+1,j+1]
  ].map { |k, l| get_value_at(lights, k, l, default, bounds) }
  index = neighbours.join("").to_i(2)
  enhancement[index]
end

def get_value_at(lights, k, l, default, bounds)
  if !in_bounds?(bounds, k, l)
    return default
  end

  lights.include?([k, l]) ? 1 : 0
end

def in_bounds?(bounds, i, j)
  i >= bounds[:x_from] &&
    i <= bounds[:x_to] &&
    j >= bounds[:y_from] &&
    j <= bounds[:y_to]
end

# for debugging
def draw(bounds, lights)
  (bounds[:x_from]-1..bounds[:x_to]+1).each do |i|
    (bounds[:y_from]-1..bounds[:y_to]+1).each do |j|
      char = lights.include?([i, j]) ? '#' : '.'
      print char
    end
    puts ""
  end
end

enhancement, bounds, lights = parse_input(filename)

num_steps.times do |i|
  default = enhancement[0] & (i % 2)
  new_bounds, new_lights = step(enhancement, bounds, lights, default)
  bounds = new_bounds
  lights = new_lights
end

puts lights.count
