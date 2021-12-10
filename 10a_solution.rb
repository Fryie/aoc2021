input = File.read("./10input.txt").split("\n").map { |l| l.split("") }

$start_chars = %w|( [ { <|
$end_chars = %w|) ] } >|

class ParseError < StandardError
  def initialize(illegal_char)
    @illegal_char = illegal_char
  end

  attr_reader :illegal_char
end

def mismatch?(start_char, end_char)
  (start_char == '(' && end_char != ')') ||
    (start_char == '[' && end_char != ']') ||
    (start_char == '{' && end_char != '}') ||
    (start_char == '<' && end_char != '>')
end

def try_parse(chars)
  stack = []

  chars.each do |char|
    if $start_chars.include?(char)
      stack.push char
    elsif $end_chars.include?(char)
      start = stack.pop
      if mismatch?(start, char)
        raise ParseError.new(char)
      end
    end
  end
end

score = input.inject(0) do |a, line|
  begin
    try_parse(line)
    a
  rescue ParseError => e
    case e.illegal_char
    when ')'
      a + 3
    when ']'
      a + 57
    when '}'
      a + 1197
    when '>'
      a + 25137
    else
      a
    end
  end
end

puts score
