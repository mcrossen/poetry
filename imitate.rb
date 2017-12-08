#!/usr/bin/env ruby

ACCURACY = 2

# expand file references
FILES = ARGV.map do |file|
    if file.end_with? "/"
        Dir.entries(file).map do |entry|
            file + entry
        end.select do |entry|
            File.file? entry
        end
    else
        [file]
    end
end.flatten(1)

# load in all references
IN_RAW = FILES.map do |file|
    File.read(file)
end

# parse the text
IN_PARSED = IN_RAW.map do |text|
    [:start] + (text.lines().map do |line|
        line.split() + [:newline]
    end.flatten(1)) + [:end]
end

# find structure
model = Hash.new
IN_PARSED.each do |text|
    current = Array.new
    text.each do |element|
        if current.size < ACCURACY
            current += [element]
        else
            model[current] = Array.new unless model.key?(current)
            unless model[current].include? element
                model[current].concat([element])
            end
            current = current.drop(1) + [element]
        end
    end
end

# choose a random start element
current = model.keys.select do |array|
    array.include? :start
end.sample

# construct a poem
out = current.map do |word|
    if word == :start
        nil
    elsif word == :newline or word == :end
        "\n"
    else
        word
    end
end.select do |word|
    word
end.join(" ")
out = out.chop if out.end_with? " "
while !current.include?(:end)
    raise Exception.new("couldn't find " + current.to_s + " in model") unless model.include? current
    next_word =  model[current].sample
    current = current.drop(1) + [next_word]
    if next_word == :newline or next_word == :end
        next_word = "\n"
    elsif !out.end_with?("\n")
        next_word = " " + next_word
    end
    out += next_word
end
out.strip!
puts out
