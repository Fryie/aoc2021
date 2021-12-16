input = File.read("16input.txt").strip

def hex2bits(hex)
  hex.split("").flat_map do |h|
    case h
    when "0"
      [0, 0, 0, 0]
    when "1"
      [0, 0, 0, 1]
    when "2"
      [0, 0, 1, 0]
    when "3"
      [0, 0, 1, 1]
    when "4"
      [0, 1, 0, 0]
    when "5"
      [0, 1, 0, 1]
    when "6"
      [0, 1, 1, 0]
    when "7"
      [0, 1, 1, 1]
    when "8"
      [1, 0, 0, 0]
    when "9"
      [1, 0, 0, 1]
    when "A"
      [1, 0, 1, 0]
    when "B"
      [1, 0, 1, 1]
    when "C"
      [1, 1, 0, 0]
    when "D"
      [1, 1, 0, 1]
    when "E"
      [1, 1, 1, 0]
    when "F"
      [1, 1, 1, 1]
    else
      raise "Invalid Hex Code"
    end
  end
end

def bits2int(bit_array)
  bit_array.join.to_i(2)
end

# returns [version, remainder, processed]
# version = sum of packet hierarchy of first package
# remainder = remaining bits after processing first package
# processed = number of bits processed for first package
def process_packet(bits)
  version = bits2int(bits[0..2])
  type = bits2int(bits[3..5])

  if type == 4
    body = bits[6..]
    remainder_start = 6

    body.each_slice(5) do |slice|
      remainder_start += 5
      if slice[0] == 0
        break
      end
    end
    [version, bits[remainder_start..], remainder_start]
  else
    version_sum = version
    length_type = bits[6]

    if length_type == 0
      total_length = bits2int(bits[7..21])
      remainder = bits[22..]
      processed = 0

      while processed < total_length
        sub_version, remainder, sub_processed = process_packet(remainder)
        version_sum += sub_version
        processed += sub_processed
      end

      [version_sum, remainder, processed+22]
    else
      packet_count = bits2int(bits[7..17])
      remainder = bits[18..]
      processed = 0

      packet_count.times do
        sub_version, remainder, sub_processed = process_packet(remainder)
        version_sum += sub_version
        processed += sub_processed
      end

      [version_sum, remainder, processed+18]
    end
  end
end

sum, _, _ = process_packet(hex2bits(input))
puts sum
