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
    if (config.has_key?("debug"))
      @debug = config["debug"] == true
    else
      @debug = false
    end
    @debug and (puts "[Info - Lwrf] initialize: Configuration Options: debug => #{@debug}" )
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
    say "LightWave is in my control using the following config file: #{LightWaveRF.new.get_config_file rescue nil}", spoken: "LightWave is in my control!"
    request_completed
  end

  # Commands to turn on/off a device in a room
  roomNamesRegEx = Regexp.union(LightWaveRF.new.get_config["room"].keys.map(&:to_s)) rescue nil
  
  listen_for (/turn (on|off) the (.*) in the (#{roomNamesRegEx})/i) { |action, deviceName, roomName| send_lwrf_command(roomName,deviceName,action) }
  listen_for (/turn (on|off) the (#{roomNamesRegEx}) (.*)/i)        { |action, roomName, deviceName| send_lwrf_command(roomName,deviceName,action) }
  listen_for (/turn the (.*) in the (#{roomNamesRegEx}) (on|off)/i) { |deviceName, roomName, action| send_lwrf_command(roomName,deviceName,action) }
  listen_for (/turn the (#{roomNamesRegEx}) (.*) (on|off)/i)        { |roomName, deviceName, action| send_lwrf_command(roomName,deviceName,action) }

  # Commands to dim a devices in a room
  listen_for (/(?:(?:dim)|(?:set)|(?:turn up)|(?:turn down)|(?:set level on)|(?:set the level on)) the (.*) in the (#{roomNamesRegEx}) to ([1-9][0-9]?)(?:%| percent)?/i) { |deviceName, roomName, action| send_lwrf_command(roomName,deviceName,action) }
  listen_for (/(?:(?:dim)|(?:set)|(?:turn up)|(?:turn down)|(?:set level on)|(?:set the level on)) the (#{roomNamesRegEx}) (.*) to ([1-9][0-9]?)(?:%| percent)?/i)        { |roomName, deviceName, action| send_lwrf_command(roomName,deviceName,action) }

  def send_lwrf_command (roomName, deviceName, action)  
    @debug and (puts "[Info - Lwrf] send_lwrf_command: Starting with arguments: roomName => #{roomName}, deviceName => #{deviceName}, roomName => #{roomName} ")
      begin
        # initialise LightWaveRF Gem
        @debug and (puts "[Info - Lwrf] send_lwrf_command: Instantiating LightWaveRF Gem")
        lwrf = LightWaveRF.new rescue nil
        @debug and (puts "[Info - Lwrf] send_lwrf_command: lwrf => #{lwrf}" )
        lwrfConfig = lwrf.get_config rescue nil
        @debug and (puts "[Info - Lwrf] send_lwrf_command: lwrfConfig => #{lwrfConfig}" )

        # Validate Inputs
        if lwrfConfig.has_key?("room") && lwrfConfig["room"].has_key?(roomName) && lwrfConfig["room"][roomName].include?(deviceName)
          say "Turning #{action} the #{deviceName} in the #{roomName}."
          lwrf.send "#{roomName}", "#{deviceName}", "#{action}", @debug rescue nil
          @debug and (puts "[Info - Lwrf] send_lwrf_command: Command sent to LightWaveRF Gem" )

        elsif lwrfConfig["room"].has_key?(roomName) 
          say "I'm sorry, I can't find '#{deviceName}' in the '#{roomName}'."

        elsif lwrfConfig.has_key?("room") 
          say "I'm sorry, I can't find '#{roomName}'."

        else    
          say "I'm sorry, I can't find either '#{roomName}' or '#{deviceName}'!"
        end

      rescue Exception
        pp $!
        say "Sorry, I encountered an error"
        @debug and (puts "[Info - Lwrf] send_lwrf_command: Error => #{$!}" )
      ensure
        request_completed
        @debug and (puts "[Info - Lwrf] send_lwrf_command: Request Completed" )
      end

    @debug and (puts "[Info - Lwrf] send_lwrf_command: Ending" )

  end

end
