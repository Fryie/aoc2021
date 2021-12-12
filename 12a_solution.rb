require 'set'

input = File.read("./12input.txt").split("\n").map do |line|
  line.split("-")
end

$edges = Hash.new { |h, k| h[k] = Set.new }

input.each do |nodeA, nodeB|
  $edges[nodeA].add nodeB
  $edges[nodeB].add nodeA
end

# returns number of paths from "from" to end
def find_paths(from, visited_small_caves)
  return 1 if from == 'end'

  $edges[from].inject(0) do |a, neighbour|
    if visited_small_caves.include? neighbour
      a
    else
      if neighbour.downcase == neighbour # small cave
        new_visited_small_caves = visited_small_caves + [neighbour]
      else
        new_visited_small_caves = visited_small_caves
      end

      a + find_paths(neighbour, new_visited_small_caves)
    end
  end
end

paths = find_paths('start', Set.new(['start']))

puts paths
