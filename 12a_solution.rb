require 'set'

input = File.read("./12input.txt").split("\n").map do |line|
  line.split("-")
end

$edges = Hash.new { |h, k| h[k] = Set.new }

input.each do |nodeA, nodeB|
  $edges[nodeA].add nodeB
  $edges[nodeB].add nodeA
end

# returns a list of paths, i.e. a list of lists of nodes
def find_paths(from, visited_edges, visited_small_caves)
  return [[from]] if from == 'end'

  $edges[from].flat_map do |neighbour|
    if visited_small_caves.include? neighbour
      nil
    elsif visited_edges.include? [from, neighbour]
      nil

    else
      new_visited_edges = visited_edges + [[from, neighbour]]

      if neighbour.downcase == neighbour # small cave
        new_visited_small_caves = visited_small_caves + [neighbour]
      else
        new_visited_small_caves = visited_small_caves
      end

      find_paths(neighbour, new_visited_edges, new_visited_small_caves).map do |subpath|
        [from] + subpath
      end
    end
  end.compact
end

paths = find_paths('start', Set.new, Set.new(['start']))

puts paths.count
