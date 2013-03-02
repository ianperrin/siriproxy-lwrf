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
    @lwrfAuth = nil
    @lwrfAuth = {:email => config["lwrfemail"], :pin => config["lwrfpin"]}
    @debug and (puts "[Info - Lwrf] initialize: Configuration Options: debug => #{@debug}, #{@lwrfAuth.to_s}" )
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

  # Command to test plugin
  listen_for /test lightwave/i do
    say "LightWave is in my control using the following config file: #{LightWaveRF.new.get_config_file rescue nil}", spoken: "LightWave is in my control!"
    request_completed
  end

  # Commands for Rooms and Devices
  LightWaveRF.new.get_config['room'].each do | room |
    room["device"].each do | deviceName |
    
      # Commands to turn on/off a device in a room
      listen_for (/turn (on|off) the (#{deviceName}) in the (#{room["name"]})/i) { |action, deviceName, roomName| send_lwrf_command(roomName,deviceName,action) }
      listen_for (/turn (on|off) the (#{room["name"]}) (#{deviceName})/i)        { |action, roomName, deviceName| send_lwrf_command(roomName,deviceName,action) }
      listen_for (/turn the (#{deviceName}) in the (#{room["name"]}) (on|off)/i) { |deviceName, roomName, action| send_lwrf_command(roomName,deviceName,action) }
      listen_for (/turn the (#{room["name"]}) (#{deviceName}) (on|off)/i)        { |roomName, deviceName, action| send_lwrf_command(roomName,deviceName,action) }

      # Commands to dim a devices in a room
      listen_for (/(?:(?:dim)|(?:set)|(?:turn up)|(?:turn down)|(?:set level on)|(?:set the level on)) the (#{deviceName}) in the (#{room["name"]}) to ([1-9][0-9]?)(?:%| percent)?/i) { |deviceName, roomName, action| send_lwrf_command(roomName,deviceName,action) }
      listen_for (/(?:(?:dim)|(?:set)|(?:turn up)|(?:turn down)|(?:set level on)|(?:set the level on)) the (#{room["name"]}) (#{deviceName}) to ([1-9][0-9]?)(?:%| percent)?/i)        { |roomName, deviceName, action| send_lwrf_command(roomName,deviceName,action) }

    end
  end

  # Commands to update config file
  listen_for (/(?:(?:update)|(?:download))(?: my)? lightwave (?:(?:config)|(?:setup)|(?:data)|(?:device list))/i) do 
    unless @lwrfAuth.nil?
      say "Updating the LightwaveRF configuration for #{@lwrfAuth[:email]} from the server"
      LightWaveRF.new.update_config @lwrfAuth[:email], @lwrfAuth[:pin], @debug rescue nil
    else
      say "I'm sorry, I don't seem to have access to the server. Have you updated the config file correctly?"
    end
    request_completed
  end
  

  def send_lwrf_command (roomName, deviceName, action)  
    begin
      @debug and (puts "[Info - Lwrf] send_lwrf_command: Starting with arguments: roomName => #{roomName}, deviceName => #{deviceName}, action => #{action} ")
      # initialise LightWaveRF Gem
      @debug and (puts "[Info - Lwrf] send_lwrf_command: Instantiating LightWaveRF Gem")
      lwrf = LightWaveRF.new rescue nil
      @debug and (puts "[Info - Lwrf] send_lwrf_command: lwrf => #{lwrf}" )
      lwrfConfig = lwrf.get_config rescue nil
      @debug and (puts "[Info - Lwrf] send_lwrf_command: lwrfConfig => #{lwrfConfig}" )

      # Validate Inputs - NB: siri passes lowercase values, but lwrf.send is case sensitive!
      if lwrfConfig.has_key?("room")
        room = lwrfConfig["room"].detect {|r| r["name"].downcase == roomName}
        if room 
          device = room["device"].detect {|d| d.downcase == deviceName} if room["device"]
          if device
            say "Turning #{action} the #{device} in the #{room["name"]}."
            lwrf.send "#{room["name"]}", "#{device}", "#{action}", @debug rescue nil
            @debug and (puts "[Info - Lwrf] send_lwrf_command: Command sent to LightWaveRF Gem" )
          else
            say "I'm sorry, I can't find '#{deviceName}' in the '#{roomName}'."
          end
        else
          say "I'm sorry, I can't find '#{roomName}'."
        end
      else    
        say "I'm sorry, I can't find either '#{roomName}' or '#{deviceName}'."
      end

    rescue Exception
      pp $!
      say "Sorry, I encountered an error"
      @debug and (puts "[Info - Lwrf] send_lwrf_command: Error => #{$!}" )
    end
    @debug and (puts "[Info - Lwrf] send_lwrf_command: Request Completed" )
    request_completed
  end

end
