require 'rest-client'
require 'json'
require 'yaml'

class  CsaRestClient
    def run
        initialise
        menu_loop
        save_config
    end  

    private

    def initialise
        read_config
        
        @api_url = @remotes[0] # default API

        @login = ""
        @password = ""
    end

    def menu_loop
        while true do
            puts "-" * @console_width
            puts "CSA REST CLIENT".center(@console_width)
            puts
            puts "Remote: #{@api_url}".center(@console_width)
            puts
            puts "1. List existing broadcasts\n" +
                 "2. Create a new broadcast\n" +
                 "3. Change remote server"
            if @login != ""
                puts "4. Logout"
            end
            puts "Q. Quit"
            
            case gets.chomp.upcase
            when "1"
                list_broadcasts
            when "2"
                create_broadcast
            when "3"
                change_remote
            when "4"
                logout
            when "Q"
                break
            else
                puts "Wrong answear, try again"
            end
        end
    end

    def logout
        @login = ""
        @password = ""
        puts "Logged out"
    end

    def change_remote
        puts "\nChose remote server:"
        @remotes.each_with_index do |remote, index|
            puts "#{index}. #{remote}"
        end
        puts "\nN. Add new remote"
        puts "Q. Back"

        answ = gets.chomp.upcase
        puts answ.ord
        if answ.to_i != 0 || answ.ord == 48     # Check if integer or string as letter.to_i is always 0 and "0".ord == 48
            @api_url = @remotes[answ.to_i]
        elsif answ == "N"
            print "URL: "
            @remotes << @api_url = gets.chomp   # Set @api_url and add to @remotes
        elsif answ == "Q"
            return
        else
            puts "\nWrong answear, try again."
        end
    end

    def list_broadcasts
        puts "BROADCASTS".center(@console_width)
        puts

        response = send_request(:get)

        if !response then return end

        broadcasts = JSON.parse(response)
        if broadcasts.length > 0
            broadcasts.each do |broadcast|
                puts "-" * @console_width

                # User / Date
                puts broadcast["created_at"].center(@console_width)
                puts ("#{broadcast["user"]["firstname"]} " +
                        "#{broadcast["user"]["surname"]} " +
                        "(ID: #{broadcast["user"]["id"]})").center(@console_width)
                puts "#{broadcast["url"]}".center(@console_width)
                
                # Feeds
                @feeds = []
                broadcast["feeds"].each do |f|
                    @feeds << f["name"]
                end
                puts @feeds.join(', ').center(@console_width)
                puts

                # Message
                puts reformat_wrapped(broadcast["content"])
                puts                    
            end
        else
            puts "There are no existing broadcasts".center(@console_width)
        end
    end

    def create_broadcast
        request = Hash.new()
        feeds = Hash.new()

        print "Message: "
        request[:broadcast] = {content: gets.chomp}
        if request[:broadcast][:content] == ""
            puts "Message cannot be empty, try again"
            return
        end

        puts "Select feds:"
        print "Email [n]: "
        if gets.chomp.upcase == 'Y'
            feeds[:email] = "1" 
        end
        print "Facebook [n]: "
        if gets.chomp.upcase == 'Y'
            feeds[:facebook] = "1"
        end
        print "RSS [n]: "
        if gets.chomp.upcase == 'Y'
            feeds[:RSS] = "1"
        end
        print "Atom [n]: "
        if gets.chomp.upcase == 'Y'
            feeds[:atom] = "1"
        end
        print "Twitter [n]: "
        if gets.chomp.upcase == 'Y'
            feeds[:twitter] = "1"

            print "Shorten URL: "
            request[:shorten_url] = gets.chomp
        end
        print "Notification feed [n]: "
        if gets.chomp.upcase == 'Y'
            feeds[:notification_feed] = "1"
        end

        if feeds.length != 0 # FIXME Why do I need to use != ?
            request[:feeds] = feeds
        else
            puts "You did not chose any feeds, try again"
            return
        end

        response = send_request(:post, request)
    end

    def send_request(method, request = {})
        if @login == ""
            puts "Please, enter your credentials:"
            print "Login: "
            @login = gets.chomp
            print "Password: "
            @password = gets.chomp
        end

        begin
            RestClient::Request.execute method: method, url: @api_url,
                        user: @login, password: @password, payload: request
        rescue => exception
            @login = ""
            @password = ""

            puts "\nWrong password or remote server down"
            puts "Error: #{exception}"
            puts
        end
        
    end

    def read_config
        begin
            config = YAML.load_file("config/config.yml")
            @console_width = config["console_width"]
            @remotes = config["remotes"]
        rescue => exception
            # If no config file found or file corrupted - set default values
            @console_width = 60
            @remotes = ['http://localhost:3000/api/broadcasts.json', 'https://csa-heroku-pab37.herokuapp.com/api/broadcasts.json']
        end     
    end

    def save_config     # FIXME or delete
        begin
            config = YAML.load_file("config/config.yml")
            config["console_width"] = @console_width
            config["remotes"] = @remotes
            File.open("config/config.yml", 'w') {|f| f.write config.to_yaml}
        rescue => exception
            puts exception
            puts "Changes will not be saved - config file not found or corrupted"
        end
    end

    # Ready solution to wrap too long broadcast's message
    # https://www.safaribooksonline.com/library/view/ruby-cookbook/0596523696/ch01s15.html
    def reformat_wrapped(s, width = @console_width)
        lines = []
	    line = ""
        s.split(/\s+/).each do |word|
            if line.size + word.size >= width
                lines << line
                line = word
            elsif line.empty?
                line = word
            else
                line << " " << word
            end
        end
        lines << line if line
        return lines.join "\n"
	end

end

csa_rest_client = CsaRestClient.new
csa_rest_client.run