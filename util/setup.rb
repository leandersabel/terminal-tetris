# Copyright 2018 Leander Sabel
# 
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy
# of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

require 'yaml'

def setup_logger(progname)
	# Load relevant configuration values
	conf = YAML::load_file('config/main.conf')
	file_format = conf['logger']['file_format']
	max_level = conf['logger']['max_level']

	# Setup logger with method input and configuration values
	date = Time.now.strftime(file_format)
	log = Logger.new("logs/#{date} - main.log")
	log.progname = progname
	log.level = max_level
	return log
end

def load_piece_configuration
	# Load game piece configuration values
	conf = YAML::load_file('config/pieces.conf')
	
	blueprints = []	
	
	# Load blueprint configuration from file
	conf.each do |piece|
		blueprints << {:type => piece[0], :color => piece[1]['color'], :points => piece[1]['points']}
	end
	
	return blueprints
end

def load_game_config
	# Load game configuration entries
	return YAML::load_file('config/main.conf')
end