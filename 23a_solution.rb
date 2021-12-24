require 'set'

# too lazy to parse this from a file
input = [
  [:C, :D],
  [:C, :A],
  [:B, :B],
  [:D, :A]
]

$hallway = (1..11).map { |i| [1, i] }.to_set
$rooms = {
  A: [[2, 3], [3, 3]],
  B: [[2, 5], [3, 5]],
  C: [[2, 7], [3, 7]],
  D: [[2, 9], [3, 9]]
}
$outside_room = [[1, 3], [1, 5], [1, 7], [1, 9]]
$cols = { A: 3, B: 5, C: 7, D: 9 }

state = {
  empty: $hallway.dup,
  occupied: {
    $rooms[:A][0] => { id: 0, val: input[0][0] },
    $rooms[:A][1] => { id: 1, val: input[0][1] },
    $rooms[:B][0] => { id: 2, val: input[1][0] },
    $rooms[:B][1] => { id: 3, val: input[1][1] },
    $rooms[:C][0] => { id: 4, val: input[2][0] },
    $rooms[:C][1] => { id: 5, val: input[2][1] },
    $rooms[:D][0] => { id: 6, val: input[3][0] },
    $rooms[:D][1] => { id: 7, val: input[3][1] }
  },
  last_move: nil
}

def neighbours(i, j)
  [[i-1, j], [i, j+1], [i+1, j], [i, j-1]]
end

def occupied_neighbours(i, j, state)
  neighbours(i, j).select do |i, j|
    state[:occupied].keys.include?([i, j])
  end
end

def matching_room?(room, mover)
  $rooms[mover[:val]].include?(room)
end

def find_open_paths(state)
  occupied = state[:occupied]

  occupied.map do |(i, j), val|
    col = $cols[val[:val]]
    below_val = occupied[[3, col]]

    if matching_room?([i, j], val) || (!below_val.nil? && below_val[:val] != val[:val])
      nil
    else
      up_path = (1..i-1).map { |k| [k, j] }.reverse

      if j < col
        horizontal_path = (j+1..col).map { |k| [1, k] }
      elsif j > col
        horizontal_path = (col..j-1).map { |k| [1, k] }.reverse
      else
        horizontal_path = []
      end

      down_path = [[2, col]]
      if below_val.nil?
        down_path << [3, col]
      end

      { components: up_path + horizontal_path + down_path, mover: val }
    end
  end.compact.select do |path|
    path[:components].all? do |component|
      state[:occupied][component].nil?
    end
  end
end

def legal_move?(state, move)
  open_paths = find_open_paths(state)
  last_move = state[:last_move]

  if !last_move.nil? && $outside_room.include?(last_move[:to]) && move[:mover] != last_move[:mover]
    return false
  end
  if $hallway.include?(move[:from]) && !$hallway.include?(move[:to]) && !matching_room?(move[:to], move[:mover])
    return false
  end
  if !last_move.nil? && last_move[:mover] != move[:mover] && $hallway.include?(move[:from]) && !open_paths.any? { |path| path[:components][0] == move[:to] && path[:mover] == move[:mover] }
    return false
  end

  # these moves are legal, but don't make sense
  if !last_move.nil? && move[:to] == last_move[:from] && move[:from] == last_move[:to]
    return false
  end

  if move[:from][0] == 3 && matching_room?(move[:from], move[:mover])
    return false
  end

  below_room = [move[:from][0]+1, move[:from][1]]
  below_state = state[:occupied][below_room]
  if !below_state.nil? && move[:from][0] == 2 && matching_room?(move[:from], move[:mover]) && matching_room?(below_room, below_state)
    return false
  end

  if !open_paths.empty? && !open_paths.any? { |path| path[:components][0] == move[:to] }
    return false
  end

  true
end

def legal_moves(state)
  state[:empty].flat_map do |i, j|
    occupied_neighbours(i, j, state).map do |k, l|
      move = {
        from: [k, l],
        to: [i, j],
        mover: state[:occupied][[k, l]]
      }

      legal_move?(state, move) ? move : nil
    end.compact
  end
end

def execute_move(state, move)
  cost = case move[:mover][:val]
         when :A
           1
         when :B
           10
         when :C
           100
         else
           1000
         end

  new_empty = state[:empty].dup
  new_empty.add move[:from]
  new_empty.delete move[:to]

  new_occupied = state[:occupied].dup
  new_occupied[move[:to]] = move[:mover]
  new_occupied.delete move[:from]

  new_state = {
    empty: new_empty,
    occupied: new_occupied,
    last_move: move
  }

  [new_state, cost]
end

def end_state?(state)
  $rooms.each do |k, v|
    v.each do |room|
      if state.dig(:occupied, room, :val) != k
        return false
      end
    end
  end

  true
end

# global variable is ugh, but I can't be bothered
$global_min = Float::INFINITY

def min_cost(cache, state, path, current_cost)
  return Float::INFINITY if current_cost == Float::INFINITY

  cached = cache[state]
  return cached + current_cost if !cached.nil?

  result = min_cost_uncached(cache, state, path, current_cost)
  unless result == Float::INFINITY
    cache[state] = result - current_cost
  end

  result
end

def min_cost_uncached(cache, state, path, current_cost)
  return current_cost if end_state?(state)

  # doesn't matter
  return Float::INFINITY if current_cost >= $global_min

  local_min = Float::INFINITY

  legal_moves(state).each do |move|
    new_state, move_cost = execute_move(state, move)
    next if path.include?(new_state)

    total_cost = min_cost(cache, new_state, path + [new_state], current_cost + move_cost)

    if total_cost < local_min
      local_min = total_cost
    end
  end

  if local_min < $global_min
    $global_min = local_min
    # for debugging
    puts $global_min
  end

  local_min
end

puts min_cost({}, state, Set.new, 0)
