def advance_all(fish_per_day)
  new_fish_per_day = fish_per_day.dup

  new_fish_per_day[8] = fish_per_day[0]
  new_fish_per_day[6] = fish_per_day[0] + fish_per_day[7]

  [0, 1, 2, 3, 4, 5, 7].each do |days|
    new_fish_per_day[days] = fish_per_day[days+1]
  end

  new_fish_per_day
end

input = File.read("./06input.txt").split(",").map(&:to_i)
fish_per_day = Hash.new { |h, k| h[k] = 0 }
input.each do |i|
  fish_per_day[i] += 1
end

256.times do |i|
  fish_per_day = advance_all(fish_per_day)
end

puts fish_per_day.inject(0) { |a, (_, v)| a + v }
