require 'rest-client'
require 'json'

class  CsaRestClient
    $login = "admin"
    $password = "taliesin"
    $api_url = 'http://localhost:3000/api/broadcasts.json'

    def print_menu
        while true do
            puts "1. Login\n2. List existing broadcasts\n3. Create a new broadcast\nQ. Quit"
            
            case gets.chomp
            when "1"
                login
            when "2"
                list_broadcasts
            when "3"
                create_broadcast
            when "q", "Q"
                break
            else
                puts "Wrong answear, try again"
            end
        end
    end

    private

    def login
        puts
    end

    def list_broadcasts
        begin
            #response = RestClient.get $api_url, user: 'admin', password: 'taliesin'
            response = RestClient::Request.execute method: :get, url: $api_url,
                            user: $login, password: $password
            puts "\nResponse code: #{response.code}\n\n"
            
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

class Broadcast
    
end

csa_rest_client = CsaRestClient.new

csa_rest_client.print_menu

    
