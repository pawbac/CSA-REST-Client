require 'rest-client'
require 'json'

class  CsaRestClient
    def run
        initialise
        menu_loop
    end  

    private

    def initialise
        @remotes = ['http://localhost:3000/api/broadcasts.json', 'https://csa-heroku-pab37.herokuapp.com/api/broadcasts.json']
        @api_url = @remotes[1] # default

        @login = "admin"
        @password = "taliesin"
    end

    def menu_loop
        while true do
            puts "\n\t\tCSA Rest Client"
            puts
            puts "Remote: #{@api_url}"
            puts
            puts "1. Login\n" +
                 "2. List existing broadcasts\n" +
                 "3. Create a new broadcast\n" +
                 "4. Change remote\n" +
                 "Q. Quit"
            
            answ = gets.chomp
            puts
            case answ
            when "1"
                login
            when "2"
                list_broadcasts
            when "3"
                create_broadcast
            when "4"
                change_remote
            when "q", "Q"
                break
            else
                puts "Wrong answear, try again"
            end
        end
    end

    def login
        puts
    end

    def change_remote
        @remotes.each_with_index do |remote, index|
            puts "#{index}. #{remote}"
        end

        answ = gets.chomp
        if @remotes.index(answ)
            @api_url = @remotes[answ]
        else
            puts "\nWrong number, try again."
        end
    end

    def list_broadcasts
        begin
            response = RestClient::Request.execute method: :get, url: @api_url,
                            user: @login, password: @password
            #puts "\nResponse code: #{response.code}\n\n"
            
            broadcasts = JSON.parse(response)
            broadcasts.each do |broadcast|
                broadcast.each do |item, value|
                    puts "#{item} = #{value}"
                end
                puts
            end
        rescue => exception
            puts exception
        end
    end

    def create_broadcast
        begin
            message = "Lalalala"
            #print "Message:"
            #message.gets
            #print "Shorten URL:" # FOR TWITTER ONLY TODO
            #short_url.gets
            #puts "Select feds:"
            #print "Email [y]:"
            #b_email.gets
            #print "Facebook [y]:"
            #b_facebook.gets
            #print "RSS [y]:"
            #b_rss.gets
            #print "Atom [y]:"
            #b_atom.gets
            #print "Twitter [y]:"
            #b_twitter.gets
            request = 
                {   
                    broadcast: {content: message},
                    #shorten_url: short_url,
                    feeds: {
                        email: "0",
                        facebook: "0",
                        RSS: "0",
                        atom: "0",
                        twitter: "0",
                        instant_messenger: "1"
                    }
                }

            response = RestClient::Request.execute method: :post, url: $api_url,
                            user: $login, password: $password, payload: request
            #puts response
        rescue => exception
            puts exception
        end
    end
end

csa_rest_client = CsaRestClient.new
csa_rest_client.run

    
