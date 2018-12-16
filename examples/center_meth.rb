win = RubyText.window(15, 65, r: 2, c: 14, fg: Green, bg: Blue)

win.puts "#center will print text centered on the current row"
win.puts "and do an implicit CRLF at the end.\n "

stuff = ["I","can","never","imagine","good sets","of real words",
         "which can somehow", "produce tree shapes", "|", "|"]

stuff.each {|str| win.center(str) }

