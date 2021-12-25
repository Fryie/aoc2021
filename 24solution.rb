require 'active_support'
require 'active_support/core_ext/array'

filename = "24input.txt"

# this code doesn't solve the problem by itself, this is done through
# staring at the instructions long enough
# it does provide functions to execute the code on inputs etc., though
# this way I can play around with my assumptions

def parse_arg(arg)
  if arg =~ /-?\d+/
    arg.to_i
  else
    arg.to_sym
  end
end

def parse_input(filename)
  File.read(filename).split("\n").map do |line|
    segments = line.split(" ")
    { op: segments[0].to_sym, args: segments.drop(1).map { |a| parse_arg(a) } }
  end
end

# split instructions into distinct steps
def split(instructions)
  instructions.split do |instruction|
    instruction[:op] == :inp
  end.map do |is|
    [{ op: :inp, args: [:w] }] + is
  end.drop(1)
end

def get(state, arg)
  if arg.is_a? Integer
    arg
  elsif [:w, :x, :y, :z].include?(arg)
    state[arg]
  else
    raise "Invalid argument"
  end
end

def execute(instructions, inputs, state=nil)
  state ||= {
    w: 0,
    x: 0,
    y: 0,
    z: 0
  }

  input_index = 0

  instructions.each do |instruction|
    store_addr = instruction[:args][0]

    state[store_addr] =
      case instruction[:op]
      when :inp
        value = inputs[input_index]
        raise "not enough inputs" if value.nil?
        input_index += 1
        value
      when :add
        state[store_addr] + get(state, instruction[:args][1])
      when :mul
        state[store_addr] * get(state, instruction[:args][1])
      when :div
        state[store_addr] / get(state, instruction[:args][1])
      when :mod
        state[store_addr] % get(state, instruction[:args][1])
      when :eql
        state[store_addr] == get(state, instruction[:args][1]) ? 1 : 0
      else
        raise "Invalid instruction"
      end
  end

  state
end

def valid_model_number?(instructions, num)
  inputs = num.to_s.split("").map(&:to_i)
  return false if inputs.any?(&:zero?)

  result = execute(instructions, inputs)

  result[:z] == 0
end

instructions = parse_input(filename)

# from reading the code we extract the following conditions
# (bi is the ith input digit):
# - b5-7 = b6
# - b4+1 = b7
# - b8+2 = b9
# - b10+5 = b11
# - b3-4 = b12
# - b2-8 = b13
# - b1+7 = b14
#
# whence we get the bounds:
# - b5 >= 8
# - b4 <= 8
# - b8 <= 7
# - b10 <= 4
# - b3 >= 5
# - b2 = 9
# - b13 = 1
# - b1 <= 2
#
# the following is the highest number satisfying these conditions
puts valid_model_number?(instructions, 29989297949519)
puts valid_model_number?(instructions, 19518121316118)
