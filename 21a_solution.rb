start_pos = [6, 3]

def mod_add1(a, b, mod)
  ((a-1+b) % mod) + 1
end

def play(player, next_rolled, current_pos)
  all_rolls = (0..2).map { |i| mod_add1(next_rolled, i, 100) }
  end_pos = mod_add1(current_pos[player], all_rolls.sum, 10)

  [all_rolls[2], end_pos]
end

winner = nil
scores = [0, 0]
next_rolled = 1
player = 0
current_pos = start_pos.dup
total_rolls = 0

while winner.nil?
  last_rolled, end_pos = play(player, next_rolled, current_pos)

  current_pos[player] = end_pos
  scores[player] += end_pos
  next_rolled = mod_add1(last_rolled, 1, 100)
  total_rolls += 3

  if scores[player] >= 1000
    winner = player
  end

  player = player == 0 ? 1 : 0
end

loser = winner == 0 ? 1 : 0
puts scores[loser] * total_rolls
