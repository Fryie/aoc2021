require 'set'

# too lazy to parse this from a file
input = [
  [:B, :A],
  [:C, :D],
  [:B, :C],
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
  last_move: nil,
  has_stopped_in_hallway: (0..7).map { |id| [id, false] }.to_h
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

def legal_move?(state, move)
  if !state[:last_move].nil? && $outside_room.include?(state[:last_move][:to]) && move[:mover] != state[:last_move][:mover]
    return false
  end
  if $hallway.include?(move[:from]) && !$hallway.include?(move[:to]) && !matching_room?(move[:to], move[:mover])
    return false
  end
  if state[:has_stopped_in_hallway][move[:mover][:id]] && $hallway.include?(move[:to])
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

  new_has_stopped_in_hallway = state[:has_stopped_in_hallway].dup
  new_has_stopped_in_hallway[move[:mover][:id]] = false
  if !state[:last_move].nil? && move[:mover] != state[:last_move][:mover] && $hallway.include?(state[:last_move][:to])
    new_has_stopped_in_hallway[state[:last_move][:mover][:id]] = true
  end

  new_state = {
    empty: new_empty,
    occupied: new_occupied,
    last_move: move,
    has_stopped_in_hallway: new_has_stopped_in_hallway
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

def min_cost(cache, state, path)
  cached = cache[state]
  return cached if !cached.nil?

  result = min_cost_uncached(cache, state, path)
  cache[state] = result

  result
end

# doesn't work: stack size too big
def min_cost_uncached(cache, state, path)
  return 0 if end_state?(state)

  min = Float::INFINITY

  legal_moves(state).each do |move|
    new_state, move_cost = execute_move(state, move)
    next if path.include?(new_state)

    min_cost_from_new = min_cost(cache, new_state, path + [new_state])
    total_cost = move_cost + min_cost_from_new

    if total_cost < min
      min = total_cost
    end
  end

  min
end

puts min_cost({}, state, Set.new)
