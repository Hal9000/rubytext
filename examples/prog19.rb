win = RubyText.window(15, 65, 1, 6, true, fg: Green, bg: Blue)

win.puts "#center will print text centered on the current row"
win.puts "and do an implicit CRLF at the end.\n "

stuff = ["I","can","never","imagine","good sets","of real words",
         "which can somehow", "produce tree shapes", "|", "|"]

stuff.each {|str| win.center(str) }

