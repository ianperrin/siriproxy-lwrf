require 'cora'
require 'siri_objects'
require 'pp'
require 'lightwaverf'

#######
# This is a SiriProxy Plugin For LightWaveRF. It simply intercepts the phrases to
# control LightWaveRF devices and responds with a message about the command that
# is sent to the LightWaveRF gem.
#
# Remember to add other plugins to the "config.yml" file if you create them!
######

class SiriProxy::Plugin::Lwrf < SiriProxy::Plugin
  def initialize(config)
    #if you have custom configuration options, process them here!
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

  listen_for /Test lightwave/i do
    say "Lightwave is in my control!"
    request_completed
  end
  
  listen_for /Turn (hallway|lounge|bedroom) (light|lamp) (on|off)/i do |room, device, action|
    say "The #{room} #{device} is being turned #{action}!"
    LightWaveRF.new.send "#{room}", "#{device}", "#{action}"
    request_completed
  end

end
