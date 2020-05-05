require 'sinatra'
require 'sinatra/reloader' if development?
require 'twilio-ruby'

configure :development do
	require 'dotenv'
	Dotenv.load
end

enable :sessions
count = 0
time = Time.now

#greeting array step 2
empty_array = []
geetings = ["Morning,", "Hello!", "Hope all is well!", "Salutations,"]
if time.hour > 10
	greeting = ["Moring,"]
else
	greeting = ["Hello!", "Hope all is well!","Salutations,"]
end

empty_array = []
LAUGH = ["its funnier in binary", "Ask your dad, he'll probably get it", "....I don't get it either"]



get '/signup/:code' do
	code = params[:code]
	if params[:code] == "secure"
		erb :views/signup
	else 404
	end
end


post '/signup/' do
	session['first_name'] = params['first_name']
	session['number'] = params['number']
	if params[:code] == "secure"
		if params['first_name'].empty
			return "Looks like we don't have a first name"
		elsif params['number'].empty
			return "We don't have an access number for you :("
		end
		client = Twilio::REST::Client.new ENV["ACd4c986b01e87537faf90c933c876cf16"], ENV["fe80d02f642238b1e2b22b05bf2a2d22"]
		meesage=	"Hi," + params['first_name'] + "Thank you for signing up! We'll be texting you at" + params['number']
		client.api.account.messages.create(
			from: ENV["TWILIO_FROM"],
			to: params[:number],
			body: message
		)
		"You're signed up. You'll receive a text message in a few minutes from the bot. "
	end
end


get "/sms/incoming" do
	session["counter"] ||= 1
	body = params[:Body] || ""
	sender = params[:From] || ""

	if session["counter"] == 1
		message = "Thanks for your first message. From #{sender} saying #{body}"
		media = nil
	else
		message = determine_response "body"
		media = nil


		# Build a twilio response object
		twiml = Twilio::TwiML::MessagingResponse.new do |r|
			r.message do |m|

				# add the text of the response
				m.body( determine_response params["body"] )

			end
		end
	end


	# increment the session counter
	session["counter"] += 1

	# send a response to twilio
	content_type 'text/xml'
	twiml.to_s

end


get '/signup' do
	"Text your name and number to begin"
end

get '/signup/:first_name/:number' do
	session['first_name'] = params['first_name']
	session['number'] = params['number']
	"Enter your name: " + params["first_name"] + " and your number: " + params["number"]
end

get '/' do
	redirect to ('/about')
end

get '/about' do
	session["visits"] ||= 0 # Set the session to 0 if it hasn't been set before
	session["visits"] = session["visits"] + 1  # adds one to the current value (increments)


	if session[:first_name]
		greetings.sample + "Good to see you again" + session[:first_name]
	else
		"My app makes the design process easier. <br> Total visits: " + session["visits"].to_s + " as of " + time.strftime("%A %B %d, %Y %H:%M").to_s
	end

end

get '/visit_count' do
	session["visits"] ||= 0 # Set the session to 0 if it hasn't been set before
	session["visits"] = session["visits"] + 1  # adds one to the current value (increments)
	"My app make the design process easier. Total visits: " + session["visits"].to_s
end


get '/test/conversation' do

	if params[:Body].nil? and params[:From].nil?
		return "Please send your message and phone number."
	elsif params[:Body].nil?
		return "What are you trying to say"
	elsif params[:From].nil?
		return "Please enter your phone number."
	else
		return determine_response params[:body]
	end
end


def determine_response body
	body = params[body].to_s
	body = body.downcase.strip

	if body == "hi"
		message = greetings.sample + "I make the design process easier"
	elsif body == "who"
		message = "This is a bot to help you pick a design process"
	elsif body== "what"
		message = "You can ask me what design process to use"
	elsif body== "where"
		message = "I live in cyberspace"
	elsif body== "when"
		message = "I was made in spring 2020"
	elsif body== "why"
		message = "I was made because there are so many design processes and choosing the right one can be a challenge"
	elsif body== "joke"
		array_of_lines = IO.readlines("jokes.txt")
		message = array_of_lines.sample +"<br>"+ LAUGH.sample.to_s
	elsif body== "facts"
		array_of_lines = IO.readlines("facts.txt")
		message = array_of_lines.sample +"<br>" + "Hard to believe I know"
	elsif body== "Y"
		message = "try asking who, what, where, when, why, or just say hi"
	else
		message = "try asking who, what, where, when, why, or just say hi"
	end

end

get "/help" do
	"Send 'Y' if you need some help."
end

get "/help/Y" do
	redirect to ('/test/conversation/:body/:from')
end

# def question body
#  if "params[:body]".end_with? ("?")
#  redirect to('/test/conversation/:body/:from')


get '/test/conversation/:body/:from' do
	determine_response params[:body]
	from = params[:from]

	if params[:body].nil?
		return "Ooops something"
	end
end


get '/test/conversation' do

	if params[:Body].nil? and params[:From].nil?
		return "Please send your message and phone number."
	elsif params[:Body].nil?
		return "What are you trying to say"
	elsif params[:From].nil?
		return "Please enter your phone number."
	else
		return determine_response params[:body]
	end
end


get '/test/conversation/:body' do
	determine_response params[:body]
end

error 403 do
	"Access Forbidden"
end
