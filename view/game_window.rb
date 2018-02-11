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

require 'curses'
require 'logger'

require_relative '../util/setup.rb'

include Curses

class GameWindow

	def initialize(field)
		@log = setup_logger('Window')
		@field = field
		@collision_map = @field.collision_map

		init_screen 				# Initialize the basic Curses screen	
		noecho							# Do not display the keys that are pressed by the user	
		nonl								# Deactivate newline on key press
		cbreak							# Do not buffer commands until the user presses 'Enter'
		curs_set(0) 				# 0 (invisible), 1 (visible) or 2 (very visible)
		start_color					# Activate colors	
		init_colors					# Initialize colors
		

		@window = Window.new(@field.size_y + 2, 
			(@field.size_x + 2) * 2, 
			lines / 2 - (@field.size_y + 2) / 2, 
			cols / 2 - @field.size_x + 2)

		  #size_x: 20
  		#size_y: 10
		
		@window.nodelay = true	# Do not wait for user input
		@window.keypad(true)		# enable arrow keys (required for pageup/down)

	end

	def listen_for_user_input
		register_user_input(@window.getch)
	end

	def draw_update	
		begin
			@window.clear

			@window.attron(color_pair(COLOR_BLACK)|A_NORMAL) {
				@window.box(" ", " ")
			}		

		  # Draw all fixed elements
		  @collision_map.each_with_index do |row, row_index|
		 		row.each_with_index do |col, col_index|
		 			draw_point(col_index, row_index, col[:color])
	  		end		  	
	  	end

	  	# Draw the active piece
	  	@field.active_piece[:points].each do |point|
	  		draw_point(point[0], point[1], @field.active_piece[:color])
	  	end

		  @window.refresh 
		rescue => ex
			@log.error ex
			close_screen
			exit
		end
	end

	def draw_point(x, y, color)
		@window.setpos(y + 1, x * 2 + 2)
			@window.attron(color_pair(get_rendering_color(color))|A_NORMAL) {
				@window.addstr("  ")
    	}
	end

	def get_rendering_color(color)
		case color
		when nil
			COLOR_BLACK
		when 'CYAN'	
			COLOR_CYAN
		when 'BLUE'	
			COLOR_BLUE	
		when 'ORANGE'	
			COLOR_WHITE
		when 'YELLOW'	
			COLOR_YELLOW
		when 'GREEN' 
			COLOR_GREEN
		when 'MAGENTA' 
			COLOR_MAGENTA	
		when 'RED' 
			COLOR_RED
		end
	end

	# Register user input and send the signal to the game field
	private def register_user_input(input) 
		case input
		when 'q'
			exit
		when Key::LEFT
			@field.move_left
		when Key::RIGHT
			@field.move_right
		when Key::DOWN
			@field.move_down
		when Key::UP
			@field.rotate
		end

		draw_update		# Draw changes to the screen
	end

	private def init_colors
	@log.info "This terminal supports RGB colors: #{can_change_color?}"

	# TODO: Implement fancy colors
	#if can_change_color? 
		# init_color(color, r, g, b)
		# TODO
	# else
		init_pair(COLOR_BLACK, COLOR_BLACK, COLOR_BLACK)
		init_pair(COLOR_BLUE, COLOR_BLUE, COLOR_BLUE)
		init_pair(COLOR_CYAN, COLOR_CYAN, COLOR_CYAN) 
		init_pair(COLOR_GREEN, COLOR_GREEN, COLOR_GREEN)
		init_pair(COLOR_MAGENTA, COLOR_MAGENTA, COLOR_MAGENTA)
		init_pair(COLOR_RED, COLOR_RED, COLOR_RED)
		init_pair(COLOR_WHITE, COLOR_WHITE, COLOR_WHITE)
		init_pair(COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW)
	# end

		
	end

end
