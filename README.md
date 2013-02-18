SiriProxy LightWaveRF Controller
================================
About
-----
A Plugin for SiriProxy to send commands to LightwaveRF devices via a LightwaveRF Wifi Link.

This plugin requires LightwaveRF hardware from http://www.lightwaverf.com/ and the LightwaveRF Gem (http://rubydoc.info/gems/lightwaverf/).

Important Note, this plugin is neither developed, nor endorsed by lightwaverf.com, do not contact them about problems or issues you encounter with this plugin. 

If you're having problems with the plugin, open an issue on github.

Installation
------------

Install SiriProxy. Some instructions for doing this on a RaspberryPi can be found here: http://www.hometoys.com/emagazine/2013/02/siri-home-automation-integration-from-start-to-finish-brpart-2--raspberry-pi-installation/2090

Edit the SiriProxy config file (`~/.siriproxy/config.yml`) so that it contains the following lines, e.g.

    - name: 'Lwrf'
      git: 'git://github.com/ianperrin/siriproxy-lwrf.git'

To view debug information, add set the debug option to true in the SiriProxy config file (`~/.siriproxy/config.yml`), e.g.
    - name: 'Lwrf'
      git: 'git://github.com/ianperrin/siriproxy-lwrf.git'
      debug: true 

Re-bundle SiriProxy, e.g.

	cd ~/SiriProxy
	rvmsudo siriproxy bundle
	rvmsudo bundle install
	rvmsudo siriproxy server

Test the plugin by saying the following command:

	"Test Lightwave"

Siri should respond by saying something like:

	"LightWave is in my control!"

Siri should also display the path of the [LightWaveRF Gem](http://rubydoc.info/gems/lightwaverf/)) config file, e.g.

	"LightWave is in my control using the config file ~/root/lightwaverf-config.yml"

Use this path to edit the config file so that it refers to the rooms and devices in your LightWaveRF setup, e.g.

	sudo nano ~/root/lightwaverf-config.yml


Usage
-----
Say things like:

* Turn 'on' the 'light' in the 'lounge'
* Turn 'on' the 'lounge' 'light'
* Turn the 'light' in the 'lounge' 'off'
* Turn the 'lounge' 'light' 'on'
* Dim the 'light' in the 'lounge' to '50' percent
* Dim the 'light' in the 'lounge' to '50'
* Dim the 'lounge' 'light' to '75' percent
* Set the 'lounge' 'light' to '75'
* Set the level on the 'lounge' 'light' to '75'

Version History
-----
* 0.0.3 - Initial Release
* 0.0.5 - Added a wider range of _natural language_ commands, rooms and device validation against the config file and support for dimming
* 0.0.6 - Removed the need to edit the plugin by dynamically creating Siri commands based on the rooms in the LightWaveRF gem configuration file

To Do
-----
* Support other methods from the LightwaveRF Gem including sequences, energy and timers
* Support aliases for room and device names
* Prompt user for options if room or device names can't be found
* Support commands to display the power usage logs/graphs

Licensing
---------
Copyright (c) 2013, Ian Perrin

Re-use of my code is fine under a Creative Commons 3.0 [Non-commercial, Attribution, Share-Alike](http://creativecommons.org/licenses/by-nc-sa/3.0/) license. In short, this means that you can use my code, modify it, do anything you want. Just don't sell it and make sure to give me a shout-out. Also, you must license your derivatives under a compatible license (sorry, no closed-source derivatives). If you would like to purchase a more permissive license (for a closed-source and/or commercial license), please contact me directly. See the Creative Commons site for more information.

Disclaimer
---------
THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
