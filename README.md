SiriProxy-LWRF
================================
About
-----
A Plugin for SiriProxy to send commands to LightwaveRF devices via a LightwaveRF Wifi Link.

This plugin requires LightwaveRF hardware from http://www.lightwaverf.com/ and the LightwaveRF Gem (http://rubydoc.info/gems/lightwaverf/).

Important Note, this plugin is neither developed, nor endorsed by lightwaverf.com, do not contact them about problems or issues you encounter with this plugin. 

If you're having problems with the plugin, open an issue on github.

Installation
------------

Install the LightwaveRF Gem (http://rubydoc.info/gems/lightwaverf/) and make sure a copy of the LightwaveRF Gem Config file (`lightwaverf-config.yml`) exists in the Home directory of the account which is being used to run SiriProxy, e.g.
	
	gem install lightwaverf

Copy this plugin into the following location, e.g:

`~/.rvm/gems/ruby-1.9.3-p385@SiriProxy/gems/siriproxy-0.3.2/plugins/`

Edit the Plugin class file (`lib/siriproxy-lwrf.rb`) so that *your* LightwaveRF rooms are listened for. For help building the regular expressions, try http://rubular.com/r/vezhtA3hA0 e.g.

	cd ~/.rvm/gems/ruby-1.9.3-p385@SiriProxy/gems/siriproxy-0.3.2/plugins/siriproxy-lwrf
	nano lib/siriproxy-lwrf.rb
	
	# e.g.
	#  listen_for /turn (on|off) the (.*) in the ((?-mix:lounge|hallway|bedroom))/i do |action, deviceName, roomName| { send_lwrf_command (roomName, deviceName, action) }
	# becomes:
	#  listen_for /turn (on|off) the (.*) in the ((?-mix:kitchen|bathroom|porch|study))/i do |action, deviceName, roomName| { send_lwrf_command (roomName, deviceName, action) }	
	
Copy the plugin, e.g.

	cp -r ~/.rvm/gems/ruby-1.9.3-p385@SiriProxy/gems/siriproxy-0.3.2/plugins/siriproxy-lwrf ~/SiriProxy/plugins/siriproxy-lwrf

Edit the SiriProxy config file (`~/.siriproxy/config.yml`) so that it contains the following lines, e.g.

    - name: 'Lwrf'
      path: './plugins/siriproxy-lwrf'

Then rebundle SiriProxy, e.g.

	cd ~/SiriProxy
	rvmsudo siriproxy bundle
	rvmsudo bundle install
	rvmsudo siriproxy server

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

To Do
-----
* Eliminate the need for modifications to the SiriProxy class file by reading the LightwaveRF Gem config file directly
* Support other methods from the LightwaveRF Gem 

Licensing
---------
Copyright (c) 2013, Ian Perrin

Re-use of my code is fine under a Creative Commons 3.0 [Non-commercial, Attribution, Share-Alike](http://creativecommons.org/licenses/by-nc-sa/3.0/) license. In short, this means that you can use my code, modify it, do anything you want. Just don't sell it and make sure to give me a shout-out. Also, you must license your derivatives under a compatible license (sorry, no closed-source derivatives). If you would like to purchase a more permissive license (for a closed-source and/or commercial license), please contact me directly. See the Creative Commons site for more information.

Disclaimer
---------
THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
