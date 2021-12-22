start_pos = [6, 3]
start_player = 0

single_rolls = [1,2,3]
possible_rolls = single_rolls.flat_map do |a|
  single_rolls.flat_map do |b|
    single_rolls.map do |c|
      [a, b, c]
    end
  end
end
$possible_roll_values = possible_rolls
  .group_by { |e| e.sum }
  .map { |k, v| [k, v.count] }
  .to_h

def mod_add1(a, b, mod)
  ((a-1+b) % mod) + 1
end

def other(player)
  player == 0 ? 1 : 0
end

def play(player, current_pos, score)
  if score[player] >= 21
    num_wins = []
    num_wins[player] = 1
    num_wins[other(player)] = 0
    return num_wins
  end
  if score[other(player)] >= 21
    num_wins = []
    num_wins[other(player)] = 1
    num_wins[player] = 0
    return num_wins
  end


  $possible_roll_values.reduce([0, 0]) do |num_wins, (value, count)|
    new_pos = []
    new_pos[player] = mod_add1(current_pos[player], value, 10)
    new_pos[other(player)] = current_pos[other(player)]

    new_score = []
    new_score[player] = score[player] + new_pos[player]
    new_score[other(player)] = score[other(player)]

    sub_num_wins = play(other(player), new_pos, new_score)

    [
      num_wins[0]+count*sub_num_wins[0],
      num_wins[1]+count*sub_num_wins[1]
    ]
  end
end

puts play(start_player, start_pos, [0, 0]).max
