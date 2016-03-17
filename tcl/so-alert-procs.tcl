#so-alert-procs.tcl
ad_library {

    SO alert package procedures
    @creation-date 13 Feb 2016
    @cvs-id $Id:
    @Copyright (c) 2016 Benjamin Brink
    @license GNU General Public License 3, see project home or http://www.gnu.org/licenses/gpl-3.0.en.html
    @project home: http://github.com/tekbasse/so-alert
    @address: po box 20, Marylhurst, OR 97036-0020 usa
    @email: tekbasse@yahoo.com

    Temporary comment about git commit comments: http://xkcd.com/1296/
}

namespace eval soa {}

# Given top, left and bottom, right positions of a near circle
# representing a sphere, 
# create a proc that converts a coordinate within the circle to
# the sphere's RA and Dec in degrees,
# and adjust these values to absolutes given the RA and DEC of the
# center position of the circle.


ad_proc -private soa::transform_circle_pos_to_sphere_coord {
    upper_left_x
    upper_left_y
    lower_right_x
    lower_right_y
} {
    Returns relative Right Ascension and Declination of a sphere
    given the upper_left and lower_right positions of a disc representing
    a sphere.
} {
    set x_y_list [list ]
    
    return $x_y_list
}

