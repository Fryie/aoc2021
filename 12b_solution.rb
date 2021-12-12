require 'set'

input = File.read("./12input.txt").split("\n").map do |line|
  line.split("-")
end

$edges = Hash.new { |h, k| h[k] = Set.new }

input.each do |nodeA, nodeB|
  $edges[nodeA].add nodeB
  $edges[nodeB].add nodeA
end

# returns two booleans: [permission, double_visited]
# - permission determines if path can be taken
# - double_visited indicates if a small cave was visited twice
def check_path(from, to, visited_caves, double_visited)
  if to == 'start'
    [false, double_visited]
  elsif to.downcase == to && visited_caves.include?(to) # visiting small cave twice
    if double_visited
      [false, true]
    else
      [true, true]
    end
  else
    [true, double_visited]
  end
end

# returns a list of paths, i.e. a list of lists of nodes
def find_paths(from, visited_caves, double_visited)
  return [[from]] if from == 'end'

  $edges[from].flat_map do |neighbour|
    permission, new_double_visited = check_path(from, neighbour, visited_caves, double_visited)

    if !permission
      nil
    else
      new_visited_caves = visited_caves + [neighbour]

      find_paths(neighbour, new_visited_caves, new_double_visited).map do |subpath|
        [from] + subpath
      end
    end
  end.compact
end

paths = find_paths('start', Set.new, false)

puts paths.count
