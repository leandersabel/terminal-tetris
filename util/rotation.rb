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


def rotate_points(points)
		# Compute the center of the elements bounding box
		element_center = get_center(points)

		# Move the element to the origin of the coordinate system to perform the rotation
		points_at_origin = points_at_origin(points, element_center)

		# Rotate using Matrix transposition
		rotated_points_at_origin = points_at_origin.map{ |arr| (Matrix[arr] * Matrix[[0,1],[-1,0]]).to_a.flatten }

		# Move the element back to the starting point on the game field
		return points_in_field(rotated_points_at_origin, element_center)
end

# ----- Private Methods -----

private def get_center(points)

	# Initialize min_x and min_y to the highest number available
	min_x = min_y = Float::MAX  
	max_x = max_y = 0

	# Compute the bounding box around the element 
	points.each do |point|
		min_x = point[0] if point[0] <= min_x
		min_y = point[1] if point[1] <= min_y
		max_x = point[0] if point[0] >= max_x
		max_y = point[1] if point[1] >= max_y
	end

	# Compute the size of the bounding box
	size_x = max_x - min_x + 1
	size_y = max_y - min_y + 1

	# Compute the center of the bounding box
	center_x = min_x + (size_x / 2)
	center_y = min_y + (size_y / 2)

	return [center_x, center_y]
end

private def points_at_origin(points, center)
	points_at_origin = []
	
	points.each do |point|
		points_at_origin << [point[0] - center[0], point[1] - center[1]]	
	end
	
	return points_at_origin
end

private def points_in_field(points, center)
	points_in_field = []
	
	points.each do |point|
		points_in_field << [point[0] + center[0], point[1] + center[1]]	
	end
	
	return points_in_field
end