def advance_all(fish)
  existing_fish = []
  new_fish = []

  fish.each do |f|
    existing, new = advance_single(f)
    existing_fish << existing
    new_fish << new unless new.nil?
  end

  existing_fish + new_fish
end

def advance_single(fish)
  if fish > 0
    [fish-1, nil]
  else
    [6, 8]
  end
end

current_fish = File.read("./06input.txt").split(",").map(&:to_i)

80.times do
  current_fish = advance_all(current_fish)
end

puts current_fish.count
