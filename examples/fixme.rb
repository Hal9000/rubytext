
files = Dir["**"].select {|x| x =~ /prog.*rb/ }

files.each do |file|
  system "tput clear"
  system "head -n 20 #{file}"
  puts "\n\n "
  print "New name = "
  name = gets.chomp
  break if name.empty?
  str = "mv #{file} #{name}.rb"
  puts str
  system str
  puts "\nEnter to continue..."
  gets
end
