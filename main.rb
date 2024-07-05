require_relative "interpreter"

def main
    puts "Ruby Brain**** Interpreter"
    puts "Type 'quit/exit' to exit."
    puts "Type 'run [path]' to run a bf file."

    loop do
        print "> "
        input = gets.chomp
        case input
        when "quit", "exit"
            break
        when /^run\s+(.+)/
            fname = "scripts/" + $1 + ".bf"
            begin
                content = File.read(fname)
                interpreter(content)
            rescue Errno::ENOENT
                puts "File '#{fname}' does not exist."
            end
        end
    end
end


main if __FILE__ == $PROGRAM_NAME