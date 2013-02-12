require 'cora'
require 'siri_objects'
require 'pp'
require 'lightwaverf'

#######
# This is a SiriProxy Plugin For LightWaveRF. It simply intercepts the phrases to
# control LightWaveRF devices and responds with a message about the command that
# is sent to the LightWaveRF gem.
######

class SiriProxy::Plugin::Lwrf < SiriProxy::Plugin

  def initialize(config)
    # get custom configuration options
    
    # initialise LightWaveRF Gem
    @lwrf = LightWaveRF.new
    @lwrfConfig = @lwrf.get_config
  end

  #get the user's location and display it in the logs
  #filters are still in their early stages. Their interface may be modified
  filter "SetRequestOrigin", direction: :from_iphone do |object|
    puts "[Info - User Location] lat: #{object["properties"]["latitude"]}, long: #{object["properties"]["longitude"]}"

    #Note about returns from filters:
    # - Return false to stop the object from being forwarded
    # - Return a Hash to substitute or update the object
    # - Return nil (or anything not a Hash or false) to have the object forwarded (along with any
    #    modifications made to it)
  end

	# Test Commands
  listen_for /test lightwave/i do
		say "LightWave is in my control using the following config file: #{@lwrf.get_config_file}", spoken: "LightWave is in my control!"
		request_completed
  end

	# Commands to turn on the devices
  listen_for (/turn (on|off) the (.*) in the ((?-mix:lounge|hallway|bedroom))/i) { |action, deviceName, roomName| send_lwrf_command(roomName,deviceName,action) }
  listen_for (/turn (on|off) the ((?-mix:lounge|hallway|bedroom)) (.*)/i) { |action, roomName, deviceName| send_lwrf_command(roomName,deviceName,action) }
  listen_for (/turn the (.*) in the ((?-mix:lounge|hallway|bedroom)) (on|off)/i) { |deviceName, roomName, action| send_lwrf_command(roomName,deviceName,action) }
  listen_for (/turn the ((?-mix:lounge|hallway|bedroom)) (.*) (on|off)/i) { |roomName, deviceName, action| send_lwrf_command(roomName,deviceName,action) }

	# Commands to dim devices
  listen_for (/(?:(?:dim)|(?:set)) the (.*) in the ((?-mix:lounge|hallway|bedroom)) to ([1-9][0-9]?)(?:%| percent)?/i) { |deviceName, roomName, action| send_lwrf_command(roomName,deviceName,action) }
  listen_for (/(?:(?:dim)|(?:set)) the ((?-mix:lounge|hallway|bedroom)) (.*) to ([1-9][0-9]?)(?:%| percent)?/i) { |roomName, deviceName, action| send_lwrf_command(roomName,deviceName,action) }
  
  def send_lwrf_command (roomName, deviceName, action)  
  	if @lwrfConfig.has_key?("room") && @lwrfConfig["room"].has_key?(roomName) && @lwrfConfig["room"][roomName].include?(deviceName)
			Thread.new {
				begin
					say "Turning #{action} the #{deviceName} in the #{roomName}."
					@lwrf.send "#{roomName}", "#{deviceName}", "#{action}"
				rescue Exception
					pp $!
					say "Sorry, I encountered an error: #{$!}"
				ensure
					request_completed
				end
			}
		elsif @lwrfConfig["room"].has_key?(roomName) 
			say "I'm sorry, I can't find '#{deviceName}' in the '#{roomName}'."
			request_completed
		elsif @lwrfConfig.has_key?("room") 
			say "I'm sorry, I can't find '#{roomName}'."
			request_completed
		else		
			say "I'm sorry, I can't find either '#{roomName}' or '#{deviceName}'!"
			request_completed
		end
  end

end
