def clamp(n: Integer, min: Integer, max: Integer)
    return n < min ? min : n > max ? max : n
end

def interpreter(text, extendedBF = false, debug = false)
    def err(ln: Integer, col: Integer, msg: String)
        puts("error on line " + String(ln) + ", col " + String(col) + ": " + msg)
    end

    cells = []
    ptr = 0

    a = 0
    while a < 30000 do cells.append(0); a += 1 end

    jumps = {}
    stack = []

    b = 0
    ln = 1
    while b < text.length do
        if text[b] == "[" then
            stack.append([b, ln])
        elsif text[b] == "]" then
            return err(ln, b + 1, "mismatched ']'") if stack.length == 0
            orig = stack.pop()[0]
            jumps[orig] = b
            jumps[b] = orig
            b += 1
        elsif text[b] == "\n"
            ln += 1
        end
        b += 1
    end

    return err(stack[-1][1], stack[-1][0] + 1, "mismatched '['") if stack.length > 0

    idx = 0
    while idx < text.length do
        #puts text[idx]
        case (text[idx])
        when "+"
            if cells[ptr] + 1 < 128 then
                cells[ptr] += 1
            elsif cells[ptr] + 1 == 128 then
                cells[ptr] = 0
            end
            idx += 1
        when "-"
            if cells[ptr] - 1 > -1 then
                cells[ptr] -= 1
            elsif cells[ptr] - 1 == -1 then
                cells[ptr] = 127
            end
            idx += 1
        when ">"
            if ptr + 1 < cells.length then
                ptr += 1 
            elsif ptr + 1 == cells.length then
                ptr = 0
            end
            idx += 1
        when "<"
            if ptr - 1 > -1 then
                ptr -= 1
            elsif ptr - 1 == -1 then
                ptr = 29999
            end
            idx += 1
        when "["
            if cells[ptr] == 0 then
                idx = jumps[idx]
                puts("jumped forward from " + String(orig) + " to " + String(idx)) if debug# + " as current cell is " + String(cells[ptr]))
            end
            idx += 1
        when "]"
            if cells[ptr] != 0 then
                orig = idx
                idx = jumps[idx]
                puts("jumped back from " + String(orig) + " to " + String(idx)) if debug
            end
            idx += 1
        when "."
            c = String({ ptr => cells[ptr] }); c[0] = ""; c[c.length-1] = ""
            puts c
            idx += 1
        when ","
            while true
                print "? "
                input = gets.chomp
                begin
                    cells[ptr] = Integer(input)
                rescue ArgumentError
                    puts "expected int in inclusive range 0-127"
                    next
                end
                break
            end
            if cells[ptr] < 0 then
                cells[ptr] = 0
                puts "input was clamped to 0 because it was out of inclusive range 0-127"
            elsif cells[ptr] > cells.length - 1 then
                cells[ptr] = 127
                puts "input was clamped to " + String(cells.length - 1) + " because it was out of inclusive range 0-127"
            end
            idx += 1

        # ExtendedBF operations
        when "*" && extendedBF
            # move the ptr forward by the amount in the current cell
            c = cells[ptr]
            if c + ptr >= cells.length then
                rem = (cells.length - 1) - (c + ptr)
                ptr = rem
            else
                ptr += c
            end
            idx += 1
        when "~" && extendedBF
            # move the ptr forward by the amount in the current cell
            c = cells[ptr]
            if ptr - c < 0 then
                sum = ptr - c
                ptr = (cells.length - 1) + sum
            else
                ptr -= c
            end
            idx += 1

        else
            idx += 1
        end
    end
end
