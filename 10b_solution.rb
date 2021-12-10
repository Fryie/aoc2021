input = File.read("./10input.txt").split("\n").map { |l| l.split("") }

$start_chars = %w|( [ { <|
$end_chars = %w|) ] } >|

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
        return 0 # ignore corrupted lines
      end
    end
  end

  stack.reverse.inject(0) do |a, e|
    value = case e
            when '('
              1
            when '['
              2
            when '{'
              3
            when '<'
              4
            else
              raise "illegal state"
            end

    a * 5 + value
  end
end

scores = input.map { |line| try_parse(line) }.reject { |s| s == 0 }
middle_score = scores.sort[(scores.size+1)/2-1]

puts middle_score
