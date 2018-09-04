#! /usr/bin/env ruby
count = 0
new_file = File.open(ARGV[0]+'_new','w')
index =  File.open(ARGV[0]+'_index','w')
tag = 'new_standard_name_'
length = 10
tag = ARGV[1] if !ARGV[1].nil?
length = ARGV[2] if !ARGV[2].nil?

File.open(ARGV[0]).each do |line|
	line.chomp!
	if line =~ /^>/
		new_name = tag+"%0#{length}d" % count
		count += 1
		new_file.puts '>'+new_name
		index.puts "#{line.gsub('>','')}\t#{new_name}"
	else
		new_file.puts line
	end
end
new_file.close
index.close
