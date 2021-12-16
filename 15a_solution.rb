require 'set'
require 'lazy_priority_queue'

input = File.read("15input.txt").split("\n").map do |line|
  line.split("").map(&:to_i)
end

class Paths
  def initialize(max_x, max_y)
    @queue = MinPriorityQueue.new
    (0..max_x).each do |x|
      (0..max_y).each do |y|
        if x == 0 && y == 0
          @queue.push [0, 0], 0
        else
          @queue.push [x, y], Float::INFINITY
        end
      end
    end
    @lengths = Hash.new { Float::INFINITY }
    @lengths[[0, 0]] = 0
    @visited = Set.new
  end

  # can only decrease
  def set(x, y, length)
    @queue.decrease_key [x, y], length
    @lengths[[x, y]] = length
  end

  def visit_next
    x, y = @queue.pop
    @visited.add [x, y]
    [x, y, length(x, y)]
  end

  def length(x, y)
    @lengths[[x, y]]
  end

  def visited?(x, y)
    @visited.include? [x, y]
  end
end

class Board
  def initialize(input)
    @board = input
    @max_x = @board.length-1
    @max_y = @board[0].length-1
  end

  attr_reader :board, :max_x, :max_y

  def end?(x, y)
    x == max_x && y == max_y
  end

  def neighbours(x, y)
    ns = []

    if x != 0
      ns << [x-1, y]
    end
    if y != 0
      ns << [x, y-1]
    end
    if x != max_x
      ns << [x+1, y]
    end
    if y != max_y
      ns << [x, y+1]
    end

    ns
  end

  def get(x, y)
    board[x][y]
  end
end

board = Board.new input
paths = Paths.new(board.max_x, board.max_y)

result = nil

while result.nil?
  x, y, length = paths.visit_next
  if board.end?(x, y)
    result = length
  else
    board.neighbours(x, y).each do |nx, ny|
      next if paths.visited?(nx, ny)

      new_length = length + board.get(nx, ny)
      if new_length < paths.length(nx, ny)
        paths.set(nx, ny, new_length)
      end
    end
  end
end

puts result
