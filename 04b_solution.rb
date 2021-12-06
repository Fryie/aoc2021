input = File.read("./04input.txt").split("\n\n")

draws = input[0].split(",").map(&:to_i)

index = Hash.new { |h, k| h[k] = [] }

boards = input.drop(1).each_with_index.map do |board, bi|
  board.split("\n").each_with_index.map do |row, ri|
    row.split(" ").each_with_index.map do |numstr, ci|
      num = numstr.to_i
      index[num] << [bi, ri, ci]

      [num, :unmarked]
    end
  end
end

all_winners = []
last_winner = nil
last_winning_draw = nil

draws.each do |num|
  index[num].each do |bi, ri, ci|
    # ignore players who have already won
    next if all_winners.include?(bi)

    boards[bi][ri][ci][1] = :marked

    horizontal_win = (0..4).all? do |ci2|
      boards[bi][ri][ci2][1] == :marked
    end
    vertical_win = (0..4).all? do |ri2|
      boards[bi][ri2][ci][1] == :marked
    end
    has_won = horizontal_win || vertical_win

    if has_won
      last_winner = boards[bi]
      last_winning_draw = num
      all_winners << bi
    end
  end
end

board_sum = last_winner
  .flatten(1)
  .select { |entry| entry[1] == :unmarked }
  .flat_map { |entry| entry[0] }
  .sum

puts board_sum * last_winning_draw
