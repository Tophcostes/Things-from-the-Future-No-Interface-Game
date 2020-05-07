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

def product_service
product_service = ["service,", "product,"]
end

def users_segement
users_segement = ["teens", "elderly", "scholars", "drag queens", "plain janes", "average joes", "tesla owners"]
end

def action
action = ["be free", "access data", "learn", "visualize", "invest", "move faster", "explore"]
end

def product_service
product_service = ["service", "product","future"]
end

def limits
product_service = ["reducing", "limiting"]
end

def negatives
product_service = ["waste", "heartbreak"]
end

def increasing
increasing = ["growing", "expanding"]
end

def positives
increasing = ["happiness", "green energy"]
end

def companies
companies = ["Slack", "Uber", "Apple"]
end


def greetings
greetings = ["Morning,", "Hello!", "Hope all is well!", "Salutations,"]
end

def sarcasm
sarcasm = ["Wow.", "Exciting.", "I'm Excited.", "Joy."]
end

def challenge_sarcasm
challenge_sarcasm = ["Yikes,", "Ooof,", "Muhahaha,", "Its your funeral,"]
end

def back_keywords body
back_keywords = ["2", "B"]
end

def start_keywords body
start_keywords = ["start", "new start", "restart"]
end

def learn_keywords body
	learn_keywords = ["3", "L"]
end

def error_response
  error_prompt = ["Sorry, I didn't get that.", "Hmm I don't know that one."].sample
  error_prompt + "" + get_commands
end

def get_commands
  error_prompt = [" I know how to:", "You can say:", "Try asking:"].sample
  return error_prompt + COMMANDS
end

COMMANDS = " who, what, where, when or why."

def laugh
laugh = ["its funnier in binary", "Ask your dad, he'll probably get it", "....I don't get it either"]
end

if time.hour > 10
	greetings = ["Moring,"]
else
	greetings = ["Hello!", "Hope all is well!","Salutations,"]
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

get '/signup' do
	"Text your name and number to begin"
end

get '/signup/:first_name/:number' do
	session['first_name'] = params['first_name']
	session['number'] = params['number']
	"Your enter your name: " + params["first_name"] + " and your number: " + params["number"]
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
		"My app makes the design process easier.\n Total visits: " + session["visits"].to_s + " as of " + time.strftime("%A %B %d, %Y %H:%M").to_s
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


get "/sms/incoming" do
	session["counter"] ||= 0
  count = session["counter"]
	body = params[:Body] || ""
	sender = params[:From] || ""

	# if session["counter"] == 1
	# 	message = "Thanks for your first message. From #{sender} saying #{body}"
	# 	media = nil
	# else
		message = determine_response body
		media = nil


		# Build a twilio response object
		twiml = Twilio::TwiML::MessagingResponse.new do |r|
			r.message do |m|
		  	m.body(message)
			end
		end
	session["counter"] += 1

	content_type 'text/xml'
	twiml.to_s

end

	def determine_response body
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
			joke_doc = IO.readlines("jokes.txt")
			message = joke_doc.sample + "\n" + laugh.sample


		elsif body== "start" or body== "new start" or body== "restart"
			message = greetings.sample + " I’m The Design Madlibs Bot {Beta}. Through me you can generate different design prompts for ideation.\nWhat can I help you with?\n(1) Generate a random design idea?\n(2) Use a specific design ideation framework?\n(3) See the sources page?\n(Home) Any time you need to come back here\n(?) learn more."
		elsif body== "home"
			message = greetings.sample + " What can I help you with?\n(1) Generate a random design idea?\n(2) Use a specific design ideation framework?\n(3) See the sources page?\n(Home) Any time you need to come back here\n(?) learn more."

		elsif body== "1"
			message = sarcasm.sample + "You must really trust me or you’re very desperate, either way, I can help.\n Text the letter (C) and I’ll get to work \n(Home) Any time you need to come start at the beginning. \h(L) learn more. "
		elsif body== "b" or body== "3"
			message = "What kinda of design would you like to explore today? Text one of the following words:
(Future) to generate a new scenarios for the soon to be.
(Service) to create a service design statement
(Interaction) to start with an idea to help define your design thingking
(Challenge) If you’re feeling brave or lazy, I’ll pick a one for you :-)
(Home) Any time you need to come start at the beginning."
elsif body== "3" or body== "l"
			message = "All original material can be found at:
http://www.practicalservicedesign.com/
http://situationlab.org/futurething-print-and-play-edition/
https://www.interaction-design.org/literature/article/stage-2-in-the-design-thinking-process-define-the-problem-and-interpret-the-results
(Home) Any time you need to come start at the beginning."
	elsif body== "future"
			message = sarcasm.sample + "The Thing From the Future is tool used for ideating ideas for futuring and design futures.
Text the letter (F) when you want to start
(B) to go back
(L) learn more."
		elsif body== "service"
			message = sarcasm.sample + "Services are notoriously complex, but having a framework for the service can really help.
Text the letter (S) when you want to start
(B) to go back
(L) learn more."
		elsif body== "interaction"
			message = sarcasm.sample + "Design thinking is one or the more well known design process, one step is defining the problem. While there are a few ways to who this, starting with a frame work is always helpful!
Text the letter (I) when you want to start
(B) to go back
(L) learn more."
		elsif body== "challenge"
			message = challenge_sarcasm.sample + "you must really trust me or you’re very desperate, either way, I can help.
Text the letter (C) and I’ll get to work
(B) to go back
(L) learn more."
		elsif body== "f"
				terrain_examples = IO.readlines("terrain.txt")
				object_examples = IO.readlines("object.txt")
				mood_examples = IO.readlines("mood.txt")
				message = "In a " + mood_examples.sample + "future, there is a " + object_examples.sample + "related to " + terrain_examples.sample + "what is it?"

		elsif body== "s"
			message = "How would a service help " + users_segement.sample + " Who want to " + action.sample + " by " + limits.sample + negatives.sample +	" and "  + increasing.sample +  positives.sample + " Unline " + companies.sample + " Wow, that’s one of my best yet. While you take it all in, if you need another one, just text the letter (C)
(B) to go back
(L) learn more."
elsif body== "i"
			message = "________ {users}needs to ________ {action}  because_________ {insight}
			If you need another one, just text the letter (I)
			(B) to go back
			(L) learn more.	"
		elsif body== "c"
			message = "How would a service " + product_service.sample + " Help " + users_segement.sample + " Who want to " + action.sample + " by " + limits.sample + negatives.sample +	" and "  + increasing.sample +  positives.sample + ". Unline" + companies.sample + " Wow, that’s one of my best yet. While you take it all in, if you need another one, just text the letter (C)
(B) to go back
(L) learn more."




		# elsif body== "future"
		# 	terrain_examples = IO.readlines("terrain.txt")
		# 	object_examples = IO.readlines("object.txt")
		# 	mood_examples = IO.readlines("mood.txt")
		# 	message = "In a " + mood_examples.sample + " future,
		# 	 there is a " + object_examples.sample +
		# 	 " related to " + terrain_examples.sample + "what is it?"

			# +"\n"+ laugh.sample
			# elsif body== "facts"
			# 	array_of_lines = IO.readlines("facts.txt")
			# 	message = array_of_lines.sample\n + "Hard to believe I know"
		elsif body== "Y"
			message = "try asking who, what, where, when, why, or just say hi"

		else
		 message = "try asking text (start) or (home)"
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

get '/test/conversation/:body' do
	determine_response params[:body]
end

error 403 do
	"Access Forbidden"
end
