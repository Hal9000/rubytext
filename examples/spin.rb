puts 'Suppose you want to display an old-fashioned "spinner"'
puts "while some long-running process finishes.\n "

puts "The spinner class method will do this (and count elapsed seconds)\n "

RubyText.spinner { 10000.times { 20000.times { 99*88 } } }

puts "\n...finished."

