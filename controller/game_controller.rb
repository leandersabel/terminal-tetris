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

require 'logger'

require_relative 'field_controller.rb'
require_relative '../util/setup.rb'
require_relative '../view/game_window.rb'

class GameController

	def initialize
		@log = setup_logger('GameController')

		@field_controller = FieldController.new

		@window = GameWindow.new(@field_controller.field)

		run_game_loop

	end


	def run_game_loop
		# Initialize next_tick to the start of the game
		next_tick = Time.now

		loop do
			# TODO: Decrease tick time as game progresses
			tick_interval = 0.5

			# Continuously refresh the game window
			@window.listen_for_user_input

			if next_tick < Time.now
				# Compute time when next game tick should be performed
				next_tick = next_tick + tick_interval
			
				@field_controller.tick

				# Draw changes to the screen
				@window.draw_update
			end
		end
	end

end

