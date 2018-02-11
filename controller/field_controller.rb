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

require_relative '../util/setup.rb'
require_relative '../model/field.rb'

class FieldController

	attr_reader :field

	def initialize
		@log = setup_logger('FieldController')

		#@log.info "Loading game pieces blueprints ..."
		@blueprints = load_piece_configuration
		@log.debug "Loaded configuration:\n#{@blueprints}"

		@log.info 'Loading game configuration ...'
		conf = load_game_config
		@log.debug "loaded configuration:\n#{conf}"

		@log.info "Create a new game field of size #{conf['field']['size_x']}x#{conf['field']['size_y']}" 
		@field = Field.new(conf['field']['size_x'],conf['field']['size_y'])
		@starting_point = {x: conf['field']['size_x'] / 2 - 2, y: 0}

		# Create the first active piece in the field
		create_new_active_piece
	end

	# Create a new random piece from the blueprints and add it to the field
	# Returns 'false' if the new piece cannot be placed due to a collision
	def create_new_active_piece
		# Get random piece from blueprints array
		blueprint = @blueprints[Random.rand(@blueprints.length)]

		# Compute active points based on starting point and relative field positions
		active_points = []
		blueprint[:points].each do |point|
			active_points << [@starting_point[:x] + point[0], @starting_point[:y] + point[1]]
		end

		# Terminate if new active piece cannot be placed on the map due to a collision
		return false if @field.collision?(active_points)

		# Write the active piece in the game field
		@field.set_active_piece(points: active_points, color: blueprint[:color], type: blueprint[:type])
	end

	# Compute the next tick of the game
	def tick
		# Attempt to move the active piece down one row
		unless @field.move_down 
			# Freeze the current active piece in the collision map
			@field.freeze_active_piece

			# Create a new active piece if the old active piece could not be moved down
			unless create_new_active_piece
				# Exit if the new piece was also blocked
				exit
				# TODO: Introduce some failure state/event to be picked up by the UI
			end
		end

		cleared_rows = @field.clear_full_rows
		# TODO: Calculate points based on cleared rows

		# Replace the current active piece with a new one if rows were cleared
		create_new_active_piece if cleared_rows > 0

		#puts @field.collision_map_to_s
		#puts "------------"

	end
end