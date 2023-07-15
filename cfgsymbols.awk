BEGIN {
	DELIM="=" ; ON = "\t" ; OFF = "" ; tabwidth=8
	for(i = 1; i<=80; i += tabwidth)
		for(j = 0; j<tabwidth; j++) TABS[i+j] = i+tabwidth
}
BEGINFILE {
	helpIndent = 0 ; choice = OFF
}

# Return the indentation of the current line, allowing for tabs
# Remove any comment, and left justify the rest (makes later regexes faster)
# If the result is an empty line, "next"
function leftjustify(text,	col, start, ch) {
	col=1
	for(start=1; start<= length() ; start++) {
		ch = substr($0, start, 1)
		if(" "==ch) col++
		else if("\t"==ch) col=TABS[col]
		else break
	}
	# Chop off any comment, unless there's a string first, when we no longer care
	# and left justify the rest
	match($0, /^[^'"#]*/)
	if("#"==substr($0, 1+RLENGTH, 1)) $0 = substr($0, start, 1+RLENGTH-start)
	else $0 = substr($0, start)

	if(0 == length()) next

	return col
}

# Return a string less the containing quotes and any embedded escaped quotes
function quotedString(text,	start, end, del) {
	start = match(text, /['"]/)	# Find string opening delimiter
	if(0==start) return ""

	del = substr(text, start, 1)
	text = substr(text, start+1)

	# Find matching delimiter
	if("'"==del) end=match(text, /[^\\]'/)
	else end=match(text, /[^\\]"/)

	if(0==end) { print "Unterminated string in:", FILENAME, $0 > "/dev/stderr" ; return "" }

	text = substr(text, 1, end)

	# Handle escape sequences
	if("'"==del) gsub(/[\\]'/, "'", text)
	else gsub(/[\\]"/, "\"", text)

	return text
}

# Read a line, possibly continued by trailing slashes
function readaline(	line, more) {
	more = $0
	line = ""
	while( "\\" == substr(more, length(more), 1) ) {
		line = line substr(more, 1, length(more)-1)
		getline more
	}
	return(line more)
}

# At last, some awk patterns and actions!
					{ $0 = readaline() ; indentation = leftjustify() }
#					{ print "Indent:", indentation, "help", helpIndent, "line:", $0 }

# Help text is introduced by the keyword "help", and is indented; it ends at the next unindented line
0<helpIndent				{ if(indentation >= helpIndent) next ; else helpIndent = 0 }
0>helpIndent				{ helpIndent = indentation ; next }
/^help\>/				{ helpIndent = -1 ; next }	# -1 means next nonblank line is first of help text

# Several Kconfig keywords are irrelevant for our purposes
#### Use proper strings, or \>
/^(comment|source|mainmenu|menu|endmenu|modules|default|depends|select|if|endif|imply|visible|range|optional)\>/	{ next }
/^def_(bool|tristate|string|hex|int)\>/	{ next }

/^(menuconfig|config)\>/		{ symbol = $2 ; next }
/^choice\>/				{ symbol = $2 ; choice = ON ; next }
/^endchoice\>/				{ choice = OFF ; next }

/^(bool|tristate|string|hex|int|prompt)\>/	{
	prompt = quotedString($0)
	if(OFF==choice) print symbol DELIM prompt
	else if(ON==choice) choice = prompt
	else print symbol DELIM choice ": " prompt
	next
}
	{ print "Unexpected line in:", FILENAME, $0 > "/dev/stderr" }
