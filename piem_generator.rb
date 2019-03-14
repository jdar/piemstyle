#!/usr/bin/env ruby -i
require 'pry'
require 'ndjson'
require 'json'
srand(1)

class Array
  def match_length_recursive(other)
    if(self[0].nil?)
      0
    elsif self[0] == other[0]
      1 + self.slice(1..-1).match_length_recursive(other.slice(1..-1))
    else
      0
    end
  end

  #returns array of length 2
  def sequence_slice_params(other,return_first: false)
    found = (0..length).map do |pos|
      if other[pos].nil?
        next
      end

      if(self[pos] == other[0])
        match_length = self[pos..-1].match_length_recursive(other)
        val = [pos, match_length]
        return(val) if(return_first && match_length > 1)
        val
      end
    end


    longest = found.compact.max_by(&:last)
    if(longest && longest.length > 1)
      longest
    else
      nil
    end
  end
end

PI = %w(3 1 4 1 5 9 2 6 5 3 5 8 9 7 9 3 2 3 8 4 6 2 6 4 3 3 8 3 2 7 9 5 0 2 8 8 4 1 9 7 1 6 9 3 9 9 3 7 5 1 0 5 8 2 0 9 7 4 9 4 4 5 9 2 3 0 7 8 1 6 4 0 6 2 ).map(&:to_i)
#PI = %w(3 1 4 1 5 9 2 6 5 3 5 8 9 7 9 3 2 3 8 4 6 2 6 4 3 3 ).map(&:to_i)
#PI = %w(3 1 4 1 5 9 2 6 5 3 ).map(&:to_i)


candidates = []
if ENV["CANDIDATES"]
  File.readlines(ENV["CANDIDATES"]).each do |line|
    begin
      if !line[/\",/]
        puts("SKIPPING: #{line}") if(ENV["VERBOSE"])
        next 
      end
      candidates << JSON.parse(line)
    rescue
    end
  end
else
  8.times do
    candidates << PI.compact
  end
end

def ndjson_format(str)
  {s: str} 
end


modify_candidate = lambda do |candidate,line_containg_obj|
  
  line = line_containg_obj[:s] || line_containg_obj["s"]
  line.gsub!(",", "")
  l = line.dup.split
  lengths1 = [l,l.map(&:length)]
  l = line.gsub("'"," ").split
  lengths2 = [l,l.map(&:length)]
  for (split_line,lengths) in [lengths1, lengths2]
    params = candidate.sequence_slice_params(lengths)
    if params 
      if ENV["MINIMUM_MATCH_LENGTH"] && (params[1] < ENV["MINIMUM_MATCH_LENGTH"].to_i)
        STDOUT.write("_") if(ENV['PROGRESS'])
        next
      end
      STDOUT.write("+") if(ENV['PROGRESS'])
      candidate.slice!(*params)
      candidate.insert(params[0],split_line[0...params[1]].join(" "))
      return true # assuming we don't want to re-use lines across candidates.
    else
      STDOUT.write(".") if(ENV['PROGRESS'])
    end
  end
  return false
end

if(ENV["CHECK"])
  candidate = PI.dup
  piem = nil
  File.readlines(ARGV[0]).each do |line|
    STDOUT.puts line
    binding.pry
    piem ||= begin
        if !line[/\",/]
          puts("SKIPPING: #{line}") if(ENV["VERBOSE"])
          next 
        end
        JSON.parse(line)
      rescue
      end
  end
  piem.map!{|el| el.is_a?(Integer) ? ("o"*el) : el }
  result = modify_candidate.call(candidate,ndjson_format(piem.join(" ")))
  if(!candidate[0].is_a?(String)) 
    puts "you should start with 3-letter words..."
  elsif !result
    puts "False! this is not a Piem. nothing was a matching line"
    puts candidate.to_json
  else
    puts "Yes! this is a Piem."
  end


else #generate

  #ARGF.each_line do |line|
  File.readlines(ARGV[0]).shuffle.each do |line|
    for candidate in candidates
      next if modify_candidate.call(candidate, JSON.parse(line))
    end
  end

  #parser = NDJSON::Parser.new( $stdin )
  #parser.each(&modify_candidate)

  File.open("piems_out/piem_#{Time.now.to_i}.txt","w+") do |f|
    candidates.each{|c| f.puts(c.select{|el| el.is_a?(Numeric)}.length.to_s); f.puts("\n"); f.puts c.to_json; f.puts("\n"); f.puts("\n") }
  end
  STDOUT.puts `ls -lastr piems_out`
end





