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
require 'matrix'

require_relative '../util/rotation.rb'

class Field

	attr_reader :size_x, :size_y, :collision_map
	attr_accessor :active_piece
	
	def initialize(size_x, size_y)
		@log = setup_logger('Field')

		@log.info "Creating a new game field with size #{size_x}x#{size_y}..."

		@size_x = size_x
		@size_y = size_y

		# Setup a 2-dimensional array to check for collisions when moving pieces
		@log.info "Setting up collision map ..."
		@collision_map = Array.new(size_y) { |i| Array.new(size_x) { |i| { value: false, color: nil }}} 
		@log.debug "Collision Map:\n#{self.to_s}"

		#set_point!([4,4],"")
	end 

	# ----- Public Methods -----

	def set_active_piece(active_piece)
		@active_piece = active_piece		
		@log.debug "Added new active piece #{@active_piece} to field}"
	end

	def freeze_active_piece
		set_points!(@active_piece[:points], @active_piece[:color] ) 
		@log.debug "Active piece #{@active_piece} frozen in collision map}"
		@active_piece = nil
	end

	# Check if an array of points could be added to the map without collision
	def collision?(points)
		points.each do |point|
			# Return true if any of the points is blocked
			return true if is_point_blocked?(point)
		end
		# Return false as none of the points is blocked
		return false
	end

	# Move the active piece down one line, if possible
	def move_down
		move([0,1])
	end

	# Move the active piece left by one column, if possible
	def move_left
		move([-1,0])
	end

	# Move the active piece left by one column, if possible
	def move_right
		move([1,0])
	end

	# Rotate the active piece clockwise, if possible
	def rotate
		# Compute the rotation using matrix transposition
		new_points = rotate_points(@active_piece[:points])

		# Update active piece (if required, i.e. no collision detected)
		@active_piece[:points] = new_points unless collision?(new_points)		
	end

	# Clear any complete rows
	# Returns the number of rows that were cleared
	def clear_full_rows

		# Clear all rows that are full
		@collision_map.each_with_index do |row, index|
			@collision_map.delete_at(index) if is_row_full?(row)
		end

		cleared_rows = @size_y - @collision_map.size

		# Create empty rows until the field is back to its original size
		while @collision_map.size < @size_y
			@collision_map.unshift( Array.new(@size_x) { |i| { value: false, color: nil }})
		end		

		return cleared_rows
	end

	# ----- Private Methods -----

	# [private] Move the active piece by a delta, if possible
	# Returns 'false' if the move was blocked by a collision
	private def move(delta)
		new_points = []
		@active_piece[:points].each do |point|
			new_points << [ point[0] + delta[0], point[1] + delta[1]]
		end
	
		# Update active piece (if required, i.e. no collision detected)
		@active_piece[:points] = new_points unless collision?(new_points)
	end

	# [private] Set multiple points in the collision map to 'true' with the appropriate color
	def set_points!(points, color)
		points.each do |point|
			set_point!(point, color)
		end
	end

	# [private] Set multiple points in the collision map to 'false' and clear the color
	def unset_points!(points)
		points.each do |point|
			unset_point!(point)
		end
	end

	# [private] Set a point in the collision map to 'true' with the appropriate color
	private def set_point!(point, color)
		update!(point, true, color)
	end

	# [private] Set a point in the collision map to 'false' and clear the color
	private def unset_point!(point) 
		update!(point, false, nil)
	end

	# [private] Check if point would be available (i.e. not used & not outside of the field)
	private def is_point_blocked?(point)
		return within_bounds?(point) ? @collision_map[point[1]][point[0]][:value] : true
	end

	# [private] Update the collision map 
	private def update!(point, value, color)
		@collision_map[point[1]][point[0]] = { value: value, color: color } if within_bounds?(point)
	end

	private def within_bounds?(point)
		return point[0] >= 0 && point[1] >= 0 && point[0] < @size_x && point[1] < @size_y
	end

	# [private] Return true if all values in the row are set to true
	private def is_row_full?(row) 
		row.each do |cell|
			return false unless cell[:value]
		end
		return true
	end

	def collision_map_to_s
		s = ""
		@collision_map.each do |row|
			row.each do |field|
				s << (field[:value] ? '[x]' : '[ ]') 
			end
			s << "\n"
		end
		return s
	end
end
