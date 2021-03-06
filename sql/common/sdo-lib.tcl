# earthquake events
# 2010-04-06
# 2010-10-25
# 2011-03-11
# 2012-04-11
# 2012-10-28
# 2013-11-17
# 2014-04-01
# 2015-04-25
# 2015-05-30
# 2015-06-16

# url for 512x512 AIA 211 images 
# SDO images begin after May 20 2010:
# http://sdo.gsfc.nasa.gov/assets/img/browse/yyyy/mm/dd/yyyymmdd_hhmmss_512_0211.jpg
# to get a list of images for one day:
# wget http://sdo.gsfc.nasa.gov/assets/img/browse/yyyy/mm/dd/

set eq_events [list 2010-04-06 2010-10-25 2011-03-11 2012-04-11 2012-10-28 2013-11-17 2014-04-01 2015-04-25 2015-05-30 2015-06-16]

# wget -w 10 --random-wait -x -i urls-one-per-line.txt

puts "proc event_date_range { event_yyyymmdd days_before days_after }"
puts "proc date_range_lister { first_yyyymmdd last_yyyymmdd } "
puts "proc sdo_browse_images_url_list { } "
puts "proc sdo_imagename_to_params_list { imagename } "
puts "proc sdo_import_imagenames { filename } "
puts "proc soho_browse_images_url_list { } "
puts "proc soho_imagename_to_params_list { }"
puts "proc soho_import_imagenames { filename }"
puts "proc 5mcse_events_import { filename } "
puts "proc 5mcle_events_import { filename } "
puts "proc usno_moon_phases { } "
puts "proc usno_moon_phases_to_dat { }"
puts "proc ace_mag_1h_to_dat { } "
puts "proc ace_sis_1h_to_dat { } "
puts "proc ace_swepam_1h_to_dat { } "
puts "proc ace_epam_1h_to_dat { } "
puts "proc ace_loc_1h_to_dat { } "
puts "proc tromsoe_mag_to_dat { } "

proc event_date_range { event_yyyymmdd days_before days_after} {
    # a date range builder 
    # for choosing a set of dates around an event
    set date_list [list ]
    set day_sec [expr { 24 * 60 * 60 } ]
    set base_sec [clock scan $event_yyyymmdd -format "%Y%m%d" ]
    set first_date_sec [expr { $day_sec * $days_before - $base_sec } ]
    set last_date_sec [expr { $day_sec * $days_before + $base_sec } ]
    for { set i $first_date_sec} { $i <= $last_date_sec } { incr i $day_sec } {
	set date [clock format $i -format "/%Y/%m/%d/%Y%m%d_"]
	lappend date_list $date
    }
    return $date_list
}

proc date_range_lister { first_yyyymmdd last_yyyymmdd {v 1}} {
    # a date range builder
    # for choosing a set of dates from first to last inclusive
    set date_list [list ]
    set day_sec [expr { 24 * 60 * 60 } ]
    set first_date_sec [clock scan $first_yyyymmdd -format "%Y%m%d" ]
    set last_date_sec [clock scan $last_yyyymmdd -format "%Y%m%d" ]
    if { $v == 1 } {
	for { set i $first_date_sec} { $i <= $last_date_sec } { incr i $day_sec } {
	    set date [clock format $i -format "/%Y/%m/%d/"]
	    lappend date_list $date
	}
    } elseif { $v == 2 } {
	for { set i $first_date_sec} { $i <= $last_date_sec } { incr i $day_sec } {
	    set date [clock format $i -format "%Y%m%d"]
	    lappend date_list $date
	}
    }
    return $date_list
}


proc sdo_browse_images_url_list { } {
    set day1 "20100521"
    set dayN "20151231"
    set day_list [date_range_lister $day1 $dayN]
    set i 0
    foreach day $day_list {
	puts "http://sdo.gsfc.nasa.gov/assets/img/browse${day}"
	incr i
    }
    puts "$i days"
}


proc sdo_imagename_to_params_list { imagename } {
    # given sdo image filename, returns parameters
    #yyyy mm dd hh mm ss width instrument or angstrom
    # modified to output yyyy-mm-dd hh:mm:ss width instr
    regexp {([2][0][1][0-6])([0-1][0-9])([0-3][0-9])[\_]([0-2][0-9])([0-6][0-9])([0-6][0-9])[\_]([0-9]+)[\_]([a-zA-Z0-9]+)[\.][j][p][g]} $imagename scratch y m d h mm s width instr
    if { ![info exists instr] } {
	puts "sdo_imagename_to_ymdhmms: error input not imagename match '${imagename}'"
    } else {
	return [list "${y}-${m}-${d}" "${h}:${mm}:${s}" $width $instr]
    }
}


proc sdo_import_imagenames { filename } {
    # returns data as a list of lists
    # in form:  $year_decimal $month_decimal $day_decimal $hour_decimal $minute_decimal $seconds $width $instrument_info
    set data_txt ""
    #  cfcount = file counter
    set cfcount 1
    set fileId [open $filename r]
    puts "reading."
    while { ![eof $fileId] } {
        #  Read entire file. 
        append data_txt [read $fileId]
	puts -nonewline "."
    }
    close $fileId
    #  split is unable to split lines consistently with \n or \r
    #  so, splitting by everything, and recompiling each line of file.
    set data_set_list [split $data_txt "\n\r\t"]
    set table_lists [list ]
    set line_count 0
    foreach {line} $data_set_list {
        #  data integrity check (minimal, because file is in a standardized format).
	set fnam [file tail $line]
	if { [string match "*.jpg" $fnam] } {
	    set data_point_list [sdo_imagename_to_params_list $fnam]
	    if { [llength $data_point_list] > 1 } {
		lappend table_lists $data_point_list
		incr line_count
	    } else {
		puts "sdo_import_imagenames: no length data_point ${data_point}"
	    }
	} else {
	    puts "sdo_import_imagenames: '${line}' not a valid filename"
	}
    }
    #  table_lists is a list of lists.

    # sort it by time and date
    set table_lists [lsort -ascii -increasing -index 1 $table_lists]
    set table_lists [lsort -ascii -increasing -index 0 $table_lists]
    puts "[llength $table_lists] data points imported to table_lists."
    # modify table, add priority and notes fields
    set table2_lists [list ]
    # can't use simple:  foreach row_list $table_lists 
    # 	lappend data_point_list 0 ""
    # because we need to follow table_lists by two indexes
    # i1 and i2
    # and then add rows after importing a whole day's set
    set table_len [llength $table_lists]
    set i1 0
    set i2 0
    set row_i2 [lindex $table_lists $i1]
    set day_i2 [lindex $row_i2 0]
    set buffer_start_i 0
    # priority uses a list of 24, and 0 for no priority
    # pattern should be like this for 24 rows:
    set priority_list [list 24 24 8 24 24 4 24 24 8 24 24 1 24 24 8 24 24 4 24 24 8 24 24 2]
    # expected max buffer size is 96, so priority ref must be within accuracy of 1 / 96.
    #set p_ref_accuracy [expr { 1. / 96. } ]
    set last_row [expr { $table_len - 1 } ]
    for {set i1 1} {$i1 < $table_len} {incr i1} {
	set row_i1 [lindex $table_lists $i1]
	set day_i1 [lindex $row_i1 0]
	if { $day_i1 ne $day_i2 || $i1 == $last_row } {
	    # i1 is new day ref
	    # i1_prev is buffer_end
	    # i2 is buffer_start
	    # set il_prev [expr { $i1 - 1 } ]
	    set buffer_len [expr { $i1 - $i2 } ]
	    # make list of priorities given that table_lists is chronologically sorted
	    # for simplicity, assume points are chronologically spaced evently
	    # and buffer results for other cases. No need to re-calc each time.
	    if { $buffer_len > 0 } {

		if { ![info exists p_b_larr(${buffer_len}) ] } {
		    # First time for this buffer size
		    #set p_b_larr(${buffer_len}) [list ]
		    # p is priority, p_i priority index
		    # default priority:
		    set p 100
		    set p_list [list ]
		    for {set i 0} {$i < $buffer_len} {incr i} {
			lappend p_list $p
		    }
		    set p_list_max_refs [llength $p_list]
		    if { $p_list_max_refs ne $buffer_len } {
			puts "at i1 $i1 i2 $i2, llength p_list not same as buffer_len. p_list is $p_list_max_refs buffer_len $buffer_len"
		    }
		    incr p_list_max_refs -1
		    # p_list is a list of 0 priorities for this buffer length
		    # Sprinkle p_list with higher ones from priority_list
		    # Max p_i ref is 23 ie 24 - 1.
		    # Max buffer ref is buffer_len - 1.
		    set b_i_per_p_i [expr { ( ( $buffer_len - 1. ) / 23. ) } ]
		    set b_i 0
		    set p_prev [lindex $priority_list 0 ]
		    for {set i 0} {$i < 24} {incr i} {
			set b_i_prev $b_i
			set b_i [expr { int( $i * $b_i_per_p_i + .01 ) } ]
			if { $b_i > $p_list_max_refs } {
			    puts "at i1 $i1 i2 $i2, b_i > p_list_max_refs b_i $b_i p_list_max_refs $p_list_max_refs p $p p_list $p_list buffer_len $buffer_len"
			    puts "setting b_i to max $p_list_max_refs"
			    set b_i $p_list_max_refs
			}


			set p [lindex $priority_list $i ]
			#puts "for i $i p $p"
			if { $b_i ne $b_i_prev|| ( $b_i eq $b_i_prev && $p < $p_prev ) } {
			    # same position, priority is higher than previous (ie lower nonzero number)
			    set p_list [lreplace $p_list $b_i $b_i $p]
			    set p_prev $p
			    #    puts "p_list: $p_list"
			} else {
			    #    puts " not true: p<p_prev $p < $p_prev "
			    #    puts " not true: b_i ne b_i_prev $b_i ne $b_i_prev"
			}
		    } 
		    if { [llength $p_list] != $buffer_len } {
			puts "Error. llength p_list not same as buffer_len p_list '${p_list}'"
		    }
		    puts "set p_b_larr(${buffer_len}) '$p_list'"
		    set p_b_larr(${buffer_len}) $p_list
		}
		# add buffer to new table
		set i 0
		set notes ""
		for {set ib $i2} {$ib < $i1} {incr ib} {
		    set b_row_list [lindex $table_lists $ib]
		    set priority [lindex $p_b_larr($buffer_len) $i]
		    lappend b_row_list $priority $notes
		    lappend table2_lists $b_row_list
		    incr i
		}
	    } else {
		puts "buffer_len is $buffer_len  This should not happen except where i1 is $last_row. i1 is $i1"
	    }
	    # new buffer reference
	    set i2 $i1
	    set day_i2 $day_i1
	}
    }

    puts "[llength $table2_lists] data points imported to table2_lists."
    puts "$filename has ${line_count} data points."


    set newfilename "sdo-ii.dat"
    set fileId [open $newfilename w]    
    foreach row_list $table2_lists {
	set row [join $row_list ";"]
#	puts $row
	puts $fileId $row
    }
    close $fileId
    puts "${newfilename} created."

    set table2_lists [lsort -integer -index 4 -increasing $table2_lists]
    set newfilename "sdo-ii-wget-sorted.dat"
    set fileId [open $newfilename w]    
#	set row "http://sdo.gsfc.nasa.gov/assets/img/browse/yyyy/mm/dd/yyyymmdd_hhmmss_512_0211.jpg"
    puts "http://sdo.gsfc.nasa.gov/assets/img/browse/yyyy/mm/dd/yyyymmdd_hhmmss_512_0211.jpg"
    foreach row_list $table2_lists {
	#set row [join $row_list ";"]
	set yyyy_mm_dd [lindex $row_list 0]
	set hh_mm_ss [lindex $row_list 1]
	set yyyy [string range $yyyy_mm_dd 0 3]
	set mm [string range $yyyy_mm_dd 5 6]
	set dd [string range $yyyy_mm_dd 8 9]
	set hh [string range $hh_mm_ss 0 1]
	set min [string range $hh_mm_ss 3 4]
	set ss [string range $hh_mm_ss 6 7]
	set size [lindex $row_list 2]
	set instr [lindex $row_list 3]
	set priority [lindex $row_list 4]
	set url "http://sdo.gsfc.nasa.gov/assets/img/browse/${yyyy}/${mm}/${dd}/${yyyy}${mm}${dd}_${hh}${min}${ss}_${size}_${instr}.jpg"

#	puts $row
	puts "$url $priority"
	puts $fileId $url
    }
    close $fileId
    puts "${newfilename} created."

}


##### soho

proc soho_browse_images_url_list { } {
    set day1 "19960115"
    set dayN "20151230"
    set day_list [date_range_lister $day1 $dayN 2]
    set i 0
    foreach day $day_list {
	#http://sohowww.nascom.nasa.gov//data/REPROCESSING/Completed/2016/eit195/20160221/
	set yyyy [string range $day 0 3]
	puts "http://sohowww.nascom.nasa.gov/data/REPROCESSING/Completed/${yyyy}/eit195/${day}/"
	incr i
    }
    puts "$i days"
}


proc soho_imagename_to_params_list { imagename } {
    # given soho image filename, returns parameters
    #yyyy mm dd hh mm  width instrument or angstrom
    # modified to output yyyy-mm-dd hh:mm width instr
#   puts "http://sohowww.nascom.nasa.gov/data/REPROCESSING/Completed/${yyyy}/eit195/${yyyy}${mm}${dd}/${yyyy}${mm}${dd}/_${hh}${min}_eit195_512.jpg"
# sohowww.nascom.nasa.gov/data/REPROCESSING/Completed/1996/eit195/19960115/19960115_2051_eit195_512.jpg
# 19990519_0445_eit195_512.jpg
    regexp {([1-2][0-9][0-9][0-9])([0-1][0-9])([0-3][0-9])[\_]([0-2][0-9])([0-6][0-9])[\_]([a-zA-Z0-9]+)[\_]([0-9]+)[\.][j][p][g]} $imagename scratch y m d h mm instr width
    if { ![info exists instr] } {
	puts "soho_imagename_to_ymdhmms: error input not imagename match '${imagename}'"
    } else {
	# for db..
	return [list "${y}-${m}-${d}" "${h}:${mm}" $width $instr]
    }
}


proc soho_import_imagenames { filename } {
    # returns data as a list of lists
    # in form:  $year_decimal $month_decimal $day_decimal $hour_decimal $minute_decimal $seconds $width $instrument_info
    set data_txt ""
    #  cfcount = file counter
    set cfcount 1
    set fileId [open $filename r]
    puts "reading."
    while { ![eof $fileId] } {
        #  Read entire file. 
        append data_txt [read $fileId]
	puts -nonewline "."
    }
    close $fileId
    #  split is unable to split lines consistently with \n or \r
    #  so, splitting by everything, and recompiling each line of file.
    set data_set_list [split $data_txt "\n\r\t"]
    set table_lists [list ]
    set line_count 0
    foreach {line} $data_set_list {
        #  data integrity check (minimal, because file is in a standardized format).
	set fnam [file tail $line]
	if { [string match "*.jpg" $fnam] } {
	    set data_point_list [soho_imagename_to_params_list $fnam]
	    if { [llength $data_point_list] > 1 } {
		lappend table_lists $data_point_list
		incr line_count
	    } else {
		puts "soho_import_imagenames: no length data_point ${line}"
	    }
	} else {
	    puts "soho_import_imagenames: '${line}' not a valid filename"
	}
    }
    #  table_lists is a list of lists.

    # sort it by time and date
    set table_lists [lsort -ascii -increasing -index 1 $table_lists]
    set table_lists [lsort -ascii -increasing -index 0 $table_lists]
    puts "[llength $table_lists] data points imported to table_lists."
    # modify table, add priority and notes fields
    set table2_lists [list ]
    # can't use simple:  foreach row_list $table_lists 
    # 	lappend data_point_list 0 ""
    # because we need to follow table_lists by two indexes
    # i1 and i2
    # and then add rows after importing a whole day's set
    set table_len [llength $table_lists]
    set i1 0
    set i2 0
    set row_i2 [lindex $table_lists $i1]
    set day_i2 [lindex $row_i2 0]
    set buffer_start_i 0
    # priority uses a list of 24, and 0 for no priority
    # pattern should be like this for 24 rows:
    set priority_list [list 24 24 8 24 24 4 24 24 8 24 24 1 24 24 8 24 24 4 24 24 8 24 24 2]
    # expected max buffer size is 96, so priority ref must be within accuracy of 1 / 96.
    #set p_ref_accuracy [expr { 1. / 96. } ]
    set last_row [expr { $table_len - 1 } ]
    for {set i1 1} {$i1 < $table_len} {incr i1} {
	set row_i1 [lindex $table_lists $i1]
	set day_i1 [lindex $row_i1 0]
	if { $day_i1 ne $day_i2 || $i1 == $last_row } {
	    # i1 is new day ref
	    # i1_prev is buffer_end
	    # i2 is buffer_start
	    # set il_prev [expr { $i1 - 1 } ]
	    set buffer_len [expr { $i1 - $i2 } ]
	    # make list of priorities given that table_lists is chronologically sorted
	    # for simplicity, assume points are chronologically spaced evently
	    # and buffer results for other cases. No need to re-calc each time.
	    if { $buffer_len > 0 } {

		if { ![info exists p_b_larr(${buffer_len}) ] } {
		    # First time for this buffer size
		    #set p_b_larr(${buffer_len}) [list ]
		    # p is priority, p_i priority index
		    # default priority:
		    set p 100
		    set p_list [list ]
		    for {set i 0} {$i < $buffer_len} {incr i} {
			lappend p_list $p
		    }
		    set p_list_max_refs [llength $p_list]
		    if { $p_list_max_refs ne $buffer_len } {
			puts "at i1 $i1 i2 $i2, llength p_list not same as buffer_len. p_list is $p_list_max_refs buffer_len $buffer_len"
		    }
		    incr p_list_max_refs -1
		    # p_list is a list of 0 priorities for this buffer length
		    # Sprinkle p_list with higher ones from priority_list
		    # Max p_i ref is 23 ie 24 - 1.
		    # Max buffer ref is buffer_len - 1.
		    set b_i_per_p_i [expr { ( ( $buffer_len - 1. ) / 23. ) } ]
		    set b_i 0
		    set p_prev [lindex $priority_list 0 ]
		    for {set i 0} {$i < 24} {incr i} {
			set b_i_prev $b_i
			set b_i [expr { int( $i * $b_i_per_p_i + .01 ) } ]
			if { $b_i > $p_list_max_refs } {
			    puts "at i1 $i1 i2 $i2, b_i > p_list_max_refs b_i $b_i p_list_max_refs $p_list_max_refs p $p p_list $p_list buffer_len $buffer_len"
			    puts "setting b_i to max $p_list_max_refs"
			    set b_i $p_list_max_refs
			}


			set p [lindex $priority_list $i ]
			#puts "for i $i p $p"
			if { $b_i ne $b_i_prev|| ( $b_i eq $b_i_prev && $p < $p_prev ) } {
			    # same position, priority is higher than previous (ie lower nonzero number)
			    set p_list [lreplace $p_list $b_i $b_i $p]
			    set p_prev $p
			    #    puts "p_list: $p_list"
			} else {
			    #    puts " not true: p<p_prev $p < $p_prev "
			    #    puts " not true: b_i ne b_i_prev $b_i ne $b_i_prev"
			}
		    } 
		    if { [llength $p_list] != $buffer_len } {
			puts "Error. llength p_list not same as buffer_len p_list '${p_list}'"
		    }
		    puts "set p_b_larr(${buffer_len}) '$p_list'"
		    set p_b_larr(${buffer_len}) $p_list
		}
		# add buffer to new table
		set i 0
		set notes ""
		for {set ib $i2} {$ib < $i1} {incr ib} {
		    set b_row_list [lindex $table_lists $ib]
		    set priority [lindex $p_b_larr($buffer_len) $i]
		    lappend b_row_list $priority $notes
		    lappend table2_lists $b_row_list
		    incr i
		}
	    } else {
		puts "buffer_len is $buffer_len  This should not happen except where i1 is $last_row. i1 is $i1"
	    }
	    # new buffer reference
	    set i2 $i1
	    set day_i2 $day_i1
	}
    }

    puts "[llength $table2_lists] data points imported to table2_lists."
    puts "$filename has ${line_count} data points."


    set newfilename "soho-ii.dat"
    set fileId [open $newfilename w]    
    foreach row_list $table2_lists {
	set row [join $row_list ";"]
#	puts $row
	puts $fileId $row
    }
    close $fileId
    puts "${newfilename} created."

    set table2_lists [lsort -integer -index 4 -increasing $table2_lists]
    set newfilename "soho-ii-wget-sorted.dat"
    set fileId [open $newfilename w]    

#  puts "http://sohowww.nascom.nasa.gov/data/REPROCESSING/Completed/${yyyy}/eit195/${yyyy}${mm}${dd}/${yyyy}${mm}${dd}_${hh}${min}_eit195_512.jpg"
     foreach row_list $table2_lists {
	#set row [join $row_list ";"]
	set yyyy_mm_dd [lindex $row_list 0]
	set hh_mm_ss [lindex $row_list 1]
	set yyyy [string range $yyyy_mm_dd 0 3]
	set mm [string range $yyyy_mm_dd 5 6]
	set dd [string range $yyyy_mm_dd 8 9]
	set hh [string range $hh_mm_ss 0 1]
	set min [string range $hh_mm_ss 3 4]
#	set ss \[string range $hh_mm_ss 6 7\]
	set size [lindex $row_list 2]
	set instr [lindex $row_list 3]
	set priority [lindex $row_list 4]
	set url "http://sohowww.nascom.nasa.gov/data/REPROCESSING/Completed/${yyyy}/eit195/${yyyy}${mm}${dd}/${yyyy}${mm}${dd}_${hh}${min}_${instr}_${size}.jpg"


#	puts $row
	puts "$url $priority"
	puts $fileId $url
    }
    close $fileId
    puts "${newfilename} created."

}



####
proc 5mcse_events_import { filename } {
    # returns data as a list of lists
    # in form:  $year_decimal $month_decimal $day_decimal $hour_decimal $minute_decimal $seconds $width $instrument_info
    set data_txt ""
    #  cfcount = file counter
    set cfcount 1
    set fileId [open $filename r]
    puts "reading."
    while { ![eof $fileId] } {
        #  Read entire file. 
        append data_txt [read $fileId]
        puts -nonewline "."
    }
    close $fileId
    #  split is unable to split lines consistently with \n or \r
    #  so, splitting by everything, and recompiling each line of file.
    # splitting by end-of-line
    set data_set_list [split $data_txt "\n\r"]
    
    # Data is in fixed-width format, so extract by columns

    # data to be fitted into table:
    # CREATE TABLE soa_earth_sun_moon_events 
    #   -- source ie catalog etc
    #   -- for example: SE
    #   -- see cross-reference soa_earth_sun_moon_events.source    
    #   source varchar(16),
    #   -- event reference assigned by source
    #   source_ref varchar(30),
    #   -- event type basic
    #   -- solar eclipse, lunar eclipse, lunar 1st qtr, lunar full moon, lunar 3rd quarter etc.
    #   -- for example:
    #   -- solar-eclipse, luna-eclipse, luna-first, luna-full luna-third, luna-new
    #   type varchar(14),
    #   -- yyyy-mm-dd
    #   date date,
    #   -- the 'center' of the event orientation
    #   time_utc time without time zone,
    #   duration_s integer,
    #   -- distance between Earth and Moon centers
    #   lunar_dist_km numeric,
    #   -- source of lunar_distance calculation
    #   lunar_dist_km_by varchar(30),
    #   -- other notes that may have been included with original data
    #   notes text



    set table_lists [list ]
    set line_count 0

    # source doesn't vary for file
    set source "5MCSE"
    foreach {line} $data_set_list {
        if { [string length $line] > 39 } {
            #  data integrity check (minimal, because file is in a standardized format).
            #  Each line must includee Sun Azm, path width and Central Duration is optional
            # so minimum width is 97 characters
            
            set source_ref [string trim [string range $line 0 4]]
            # se = solar eclipse
            set type "SE-"
            append type [string trim [string range $line 55 58]]
            #  Eclipse Type where:
            #    Type         P  = Partial Eclipse.
            #                 A  = Annular Eclipse.
            #                 T  = Total Eclipse.
            #                 H  = Hybrid or Annular/Total Eclipse.
            #               Second character in Eclipse Type:
            #                 "m" = Middle eclipse of Saros series.
            #                 "n" = Central eclipse with no northern limit.
            #                 "s" = Central eclipse with no southern limit.
            #                 "+" = Non-central eclipse with no northern limit.
            #                 "-" = Non-central eclipse with no southern limit.
            #                 "2" = Hybrid path begins total and ends annular.
            #                 "3" = Hybrid path begins annular and ends total.
            #                 "b" = Saros series begins (first eclipse in series).
            #                 "e" = Saros series ends (last eclipse in series).
            # types from http://eclipse.gsfc.nasa.gov/SEcat5/SEcatkey.html

            # (year-sign or blank) yyyy
            set sign [string trim [string range $line 12 12]]
            if { $sign eq "" } {
                set ee "A.D."
                set ee2 "C.E."
                set ee_sql "AD"
            } else {
                set ee "B.C."
                set ee2 "B.C.E."
                set ee_sql "BC"
            }

            set yyyy [string trim [string range $line 13 16]]
            set h [string trim [string range $line 18 20]]
            set dd [string trim [string range $line 22 23]]
            #set date_s \[clock scan "$yyyy-$h-$dd $ee" -format "%Y-%h-%d %EE"\]
            # If this were to be formated back to tcl:
            #set date \[clock $date_s -format "%Y-%m-%d %EE"\]
            # or
            #set date \[clock scan $yyyy-$h-$dd -format "%Y-%h-%d%EE"\]
            # but we're formatting for sql input
            # dt = dynamical time, see SEcatkey
            set time_dt [string range $line 26 33] 
            #puts "$line_count $yyyy-$h-$dd $ee ${time_dt}"
            set date_time_s [clock scan "$yyyy-$h-$dd $ee ${time_dt}" -format "%Y-%h-%d %EE %H:%M:%S"]
            #   time_utc time without time zone,
            set t_delta [string trim [string range $line 35 40]]

            # delta_t = time_dt - time_utc  per eclipse.gsfc.nasa.gov/SEcat5/deltat.html
            set datetime_utc_s [expr { $date_time_s - $t_delta } ]
            set date [clock format $datetime_utc_s -format "%Y-%m-%d %EE"]
            regsub -- $ee2 $date $ee_sql date
            puts "$line_count $date"
            set time_utc [clock format $datetime_utc_s -format "%H:%M:%S"]
            #   duration_s integer,
            # remove leading zeros and spaces
            set duration [string trim [string range $line 105 110]]
            if { [string length $duration] < 6 } {
                # partial eclipse or other, ie 0
                set duration_s 0
            } else {
                set duration_m [string trimleft [string range $duration 0 1] "0"]
                if { $duration_m eq "" } {
                    set duration_m 0
                }
                set duration_s [string trimleft [string range $duration 3 4] "0"]
                if { $duration_s eq "" } {
                    set duration_s 0
                }
                set duration_s [expr { $duration_m * 60 + $duration_s } ]
            }
            #   -- distance between Earth and Moon centers
            #   lunar_dist_km numeric,
            set lunar_dist_km ""
            #   -- source of lunar_distance calculation
            #   lunar_dist_km_by varchar(30),
            set lunar_dist_km_by ""
            #   -- other notes that may have been included with original data
            #   notes text
            set notes ""
            set record_list [list $source $source_ref $type $date $time_utc $duration_s $lunar_dist_km $lunar_dist_km_by $notes]
            lappend table_lists $record_list
            incr line_count
        }
    }
    #  table_lists is a list of lists.

    # sort it by time and date
    #set table_lists \[lsort -ascii -increasing -index 1 $table_lists\]
    #set table_lists \[lsort -ascii -increasing -index 0 $table_lists\]
    puts "[llength $table_lists] data points imported to table_lists."
    # modify table, add priority and notes fields
    puts "$filename has ${line_count} data points."


    set newfilename "solar-eclipse.dat"
    set fileId [open $newfilename w]    
    foreach row_list $table_lists {
        set row [join $row_list ";"]
        #	puts $row
        puts $fileId $row
    }
    close $fileId
    puts "${newfilename} created."

}


proc 5mcle_events_import { filename } {


    set data_txt ""
    #  cfcount = file counter
    set cfcount 1
    set fileId [open $filename r]
    puts "reading."
    while { ![eof $fileId] } {
        #  Read entire file. 
        append data_txt [read $fileId]
        puts -nonewline "."
    }
    close $fileId
    #  split is unable to split lines consistently with \n or \r
    #  so, splitting by everything, and recompiling each line of file.
    # splitting by end-of-line
    set data_set_list [split $data_txt "\n\r"]
    
    # Data is in fixed-width format, so extract by columns

    # data to be fitted into table:
    # CREATE TABLE soa_earth_sun_moon_events 
    #   -- source ie catalog etc
    #   -- for example: SE
    #   -- see cross-reference soa_earth_sun_moon_events.source    
    #   source varchar(16),
    #   -- event reference assigned by source
    #   source_ref varchar(30),
    #   -- event type basic
    #   -- solar eclipse, lunar eclipse, lunar 1st qtr, lunar full moon, lunar 3rd quarter etc.
    #   -- for example:
    #   -- solar-eclipse, luna-eclipse, luna-first, luna-full luna-third, luna-new
    #   type varchar(14),
    #   -- yyyy-mm-dd
    #   date date,
    #   -- the 'center' of the event orientation
    #   time_utc time without time zone,
    #   duration_s integer,
    #   -- distance between Earth and Moon centers
    #   lunar_dist_km numeric,
    #   -- source of lunar_distance calculation
    #   lunar_dist_km_by varchar(30),
    #   -- other notes that may have been included with original data
    #   notes text



    set table_lists [list ]
    set line_count 0

    # source doesn't vary for file
    set source "5MCLE"
    foreach {line} $data_set_list {
        if { [string length $line] > 39 } {
            #  data integrity check (minimal, because file is in a standardized format).
            #  Each line must includee Sun Azm, path width and Central Duration is optional
            # so minimum width is 97 characters
            
            set source_ref [string trim [string range $line 0 4]]
            # le = solar eclipse
            set type "LE-"
            append type [string trim [string range $line 55 58]]
            #  Eclipse Type where:
            #Type         N  = Penumbral Lunar Eclipse.
            #             P  = Partial Lunar Eclipse (in umbra).
            #             T  = Total Lunar Eclipse (in umbra).
            #           Second character in Eclipse Type:
            #             "m" = Middle eclipse of Saros series.
            #             "+" = Central total eclipse 
            #                   (Moon's center passes north of shadow axis).
            #             "-" = Central total eclipse 
            #                   (Moon's center passes south of shadow axis).
            #             "*" = Total penumbral lunar eclipse.
            #             "b" = Saros series begins (first penumbral eclipse in series).
            #             "e" = Saros series ends (last penumbral eclipse in series).

            # (year-sign or blank) yyyy
            set sign [string trim [string range $line 7 7]]
            if { $sign eq "" } {
                set ee "A.D."
                set ee2 "C.E."
                set ee_sql "AD"
            } else {
                set ee "B.C."
                set ee2 "B.C.E."
                set ee_sql "BC"
            }

            set yyyy [string trim [string range $line 8 11]]
            set h [string trim [string range $line 13 15]]
            set dd [string trim [string range $line 17 18]]
            #set date_s \[clock scan "$yyyy-$h-$dd $ee" -format "%Y-%h-%d %EE"\]
            # If this were to be formated back to tcl:
            #set date \[clock $date_s -format "%Y-%m-%d %EE"\]
            # or
            #set date \[clock scan $yyyy-$h-$dd -format "%Y-%h-%d%EE"\]
            # but we're formatting for sql input
            # dt = dynamical time, see SEcatkey
            set time_dt [string range $line 21 28] 
            #puts "$line_count $yyyy-$h-$dd $ee ${time_dt}"
            set date_time_s [clock scan "$yyyy-$h-$dd $ee ${time_dt}" -format "%Y-%h-%d %EE %H:%M:%S"]
            #   time_utc time without time zone,
            set t_delta [string trim [string range $line 31 35]]

            # delta_t = time_dt - time_utc  per eclipse.gsfc.nasa.gov/SEcat5/deltat.html
            set datetime_utc_s [expr { $date_time_s - $t_delta } ]
            set date [clock format $datetime_utc_s -format "%Y-%m-%d %EE"]
            regsub -- $ee2 $date $ee_sql date
            puts "$line_count $date"
            set time_utc [clock format $datetime_utc_s -format "%H:%M:%S"]
            #   duration_s integer,
            # remove leading zeros and spaces using trimleft "0"
            set duration [string trim [string range $line 84 102]]
            # duration can be in three parts, Pen. Par. Total(shadow)
            # Pen. is longest, so lets use it.
            set duration_m [string trimleft [string range $duration 0 4] " 0-"]
            if { [string length $duration_m] < 2 } {
                # shouldn't happen since all lunar eclipses have a pen. shadow
                set duration_s 0
                puts "Warning(1): duration_s 0 for catalog# $source_ref  This should NOT happen."
            } else {
                set duration_s [expr { round( $duration_m * 60. ) } ]
            }
            #   -- distance between Earth and Moon centers
            #   lunar_dist_km numeric,
            set lunar_dist_km ""
            #   -- source of lunar_distance calculation
            #   lunar_dist_km_by varchar(30),
            set lunar_dist_km_by ""
            #   -- other notes that may have been included with original data
            #   notes text
            set duration_tot [string trimleft [string range $duration end-4 end] " 0-"]
            if { $duration_tot ne "" } {
                set duration_tot [expr { $duration_tot * 60 } ]
                set notes "Totality ${duration_tot} s."
            } else {
                set notes ""
            }
            set record_list [list $source $source_ref $type $date $time_utc $duration_s $lunar_dist_km $lunar_dist_km_by $notes]
            lappend table_lists $record_list
            incr line_count
        }
    }
    #  table_lists is a list of lists.

    # sort it by time and date
    #set table_lists \[lsort -ascii -increasing -index 1 $table_lists\]
    #set table_lists \[lsort -ascii -increasing -index 0 $table_lists\]
    puts "[llength $table_lists] data points imported to table_lists."
    # modify table, add priority and notes fields
    puts "$filename has ${line_count} data points."


    set newfilename "lunar-eclipse.dat"
    set fileId [open $newfilename w]    
    foreach row_list $table_lists {
        set row [join $row_list ";"]
        #	puts $row
        puts $fileId $row
    }
    close $fileId
    puts "${newfilename} created."

}

proc usno_moon_phases { } {
    set newfilename "moon-phases-wget.txt"
    set fileId [open $newfilename w]    

    for {set y 1900} {$y < 2100} {incr y} {
        # one query per year, maybe with extras
        set row "http://aa.usno.navy.mil/cgi-bin/aa_phases.pl?year=${y}&month=1&day=1&nump=55&format=t"
        puts $fileId $row
    }
    close $fileId
    puts "${newfilename} created."

}

proc usno_moon_phases_to_dat { } {
    set oldfilename "aa.usno.navy.mil/one-big-lunar-phase-file.html"

    set data_txt ""
    #  cfcount = file counter
    set cfcount 1
    set fileId [open $oldfilename r]
    puts "reading."
    while { ![eof $fileId] } {
        #  Read entire file. 
        append data_txt [read $fileId]
        puts -nonewline "."
    }
    close $fileId
    # get rid of extra spaces and all EOLs
    regsub -all -- {[\ \t\n]+} $data_txt { } data2_txt

    # create a new line for each table row
    regsub -all -- {<tr>} $data2_txt "\n" data3_txt
    regsub -all -- {</tr>} $data3_txt "\n" data4_txt
    
    #  split is unable to split lines consistently with \n or \r
    #  so, splitting by everything, and recompiling each line of file.
    # splitting by end-of-line
    set data1_list [split $data4_txt "\n"]
    set data2_lists [list ]

    set source "aa.usno"
    # aa.usno = Astronimical Applications dept of the USNO, http://aa.usno.navy.mil/
    set duration_s ""
    set lunar_dist_km ""
    set lunar_dist_km_by ""
    
    foreach line $data1_list {
        # is this a data row?
        if { [regexp -nocase -- {^[\ ]*[\<][t][d][\>]([a-z\ ]+)[\<][\/][t][d][\>][\ ]*[\<][t][d][\>]([0-9a-z\ \:\-]+)[\<][\/][t][d][\>][\ ]$} $line scratch type_desc datetime_utc] } {
            set notes ""

            # parse type to pseudo 5MC nasa eclipse types
            set type_desc [string trim $type_desc]
            regsub -nocase -- { } $type_desc {} type_name 
            switch -nocase -- $type_name {
                NewMoon { 
                    set type "LNM"
                }
                FirstQuarter {
                    set type "LFQ"
                }
                FullMoon {
                    set type "LFM"
                }
                LastQuarter {
                    set type "LLQ"
                }
                default {
                    set type "L??"
                    set notes "unknown moon phase entry"
                    puts "unknown moon phase entry '$type_desc'"
                }
            }
            # parse time
            set yyyy [string range $datetime_utc 0 3]
            set h [string range $datetime_utc 5 7]
            set dd [string range $datetime_utc 9 10]
            #set ee "A.D."
            set time_utc [string range $datetime_utc 12 16]
            set date_time_s [clock scan "$yyyy-$h-$dd ${time_utc}" -format "%Y-%h-%d %H:%M"]
            #   time_utc time without time zone,
            set date [clock format $date_time_s -format "%Y-%m-%d"]
            set time_utc [clock format $date_time_s -format "%H:%M"]
            set source_ref "${yyyy}-${h}-${dd}"

            set new_line_list [list $source $source_ref $type $date $time_utc $duration_s $lunar_dist_km $lunar_dist_km_by $notes]
            lappend data2_lists $new_line_list
        } else {
            if { [string length $line] > 10 } {
                set maybe_data_p 0
                set check_list [list moon jan feb mar apr may jun jul aug sep oct nov dec ]
                foreach check $check_list {
                    set maybe_data_p [expr { [string match -nocase $check $line] || $maybe_data_p } ]
                }
                if { $maybe_data_p } {
                    puts "rejected -->$line"
                }
               # puts "rejected '[string range $line 0 20]..[string range $line end-9 end]'"
            }
        }
    }
    puts "[llength $data2_lists] points with duplicates"
    # remove duplicates
    set data3_lists [lsort -increasing -ascii -index 1 -unique $data2_lists]
    puts "[llength $data3_lists] points without duplicates"

    set newfilename "lunar-phase.dat"
    set fileId [open $newfilename w]    
    foreach row_list $data3_lists {
        set row [join $row_list ";"]
        #	puts $row
        puts $fileId $row
    }
    close $fileId
    puts "${newfilename} created."

}



proc ace_mag_1h_to_dat { } {
    # ace_mag_1h
    # ace_sis_1h
    # ace_swepam_1h
    # ace_epam_1h
    # ace_loc_1h

    set oldfilename "/home/beta/so-corona-hole/sohoftp.nascom.nasa.gov/all_mag_1h.txt"
    set newfilename "ace_mag_1h.dat"
    set data_txt ""
    #  cfcount = file counter
    set cfcount 1
    set fileId [open $oldfilename r]
    puts "reading."
    while { ![eof $fileId] } {
        #  Read entire file. 
        append data_txt [read $fileId]
        puts -nonewline "."
    }
    close $fileId
    # get rid of extra spaces and all EOLs
    # create a new line for each table row
    #  split is unable to split lines consistently with \n or \r
    #  so, splitting by everything, and recompiling each line of file.
    # splitting by end-of-line
    set data1_list [split $data_txt "\n"]

    # data file is fixed-width format
    set data2_lists [list ]
    #       -- yyyy-mm-dd
    #       date date,
    #       -- hh::mm
    #       time_utc time without time zone,
    #       -- seconds
    #       duration_s integer,
    #       --  Status(S): 0 = nominal data, 1 to 8 = bad data record, 9 = no data
    #       status varchar(1),
    #       -- Bx ie magnentic field x-axis
    #       bx numeric,
    #       -- By ie ma...
    #       by numeric,
    #       bz numeric,
    #       bt numeric,
    #       latitude numeric,
    #       longitude numeric

    set duration_s "3600"
    
    foreach line $data1_list {
        # parse time
        if { [string length $line ] > 84 } {
            set yyyy [string range $line 0 3]
            set mm [string range $line 5 6]
            set dd [string range $line 8 9]
            set hour [string range $line 12 13]
            set min [string range $line 14 15]
            
            set time_utc "${hour}:${min}"
            set date "${yyyy}-${mm}-${dd}"
            set status [string range $line 36 36]
            set bx [string trim [string range $line 38 44]]
            set by [string trim [string range $line 46 52]]
            set bz [string trim [string range $line 54 60]]
            set bt [string trim [string range $line 62 68]]
            set lat [string trim [string range $line 70 76]]
            set lon [string trim [string range $line 78 84]]
            set new_line_list [list $date $time_utc $duration_s $status $bx $by $bz $bt $lat $lon]
            
            lappend data2_lists $new_line_list
        } else {
            if { [string length $line] > 10 } {
                set maybe_data_p 1
                if { $maybe_data_p } {
                    puts "rejected -->$line"
                }
                # puts "rejected '[string range $line 0 20]..[string range $line end-9 end]'"
            }
        }

    }
    puts "[llength $data2_lists] points"
    
    
    set fileId [open $newfilename w]    
    foreach row_list $data2_lists {
        set row [join $row_list ";"]
        #	puts $row
        puts $fileId $row
    }
    close $fileId
    puts "${newfilename} created."
    
}


proc ace_sis_1h_to_dat { } {
    # ace_mag_1h
    # ace_sis_1h
    # ace_swepam_1h
    # ace_epam_1h
    # ace_loc_1h

    set oldfilename "/home/beta/so-corona-hole/sohoftp.nascom.nasa.gov/all_sis_1h.txt"
    set newfilename "ace_sis_1h.dat"
    set data_txt ""
    #  cfcount = file counter
    set cfcount 1
    set fileId [open $oldfilename r]
    puts "reading."
    while { ![eof $fileId] } {
        #  Read entire file. 
        append data_txt [read $fileId]
        puts -nonewline "."
    }
    close $fileId
    # get rid of extra spaces and all EOLs
    # create a new line for each table row
    #  split is unable to split lines consistently with \n or \r
    #  so, splitting by everything, and recompiling each line of file.
    # splitting by end-of-line
    set data1_list [split $data_txt "\n"]

    # data file is fixed-width format
    set data2_lists [list ]
#       -- yyyy-mm-dd
#       date date,
#       -- hh::mm
#       time_utc time without time zone,
#       -- seconds, refers to change in time per data point
#       duration_s integer,
#       --  Status(S): 0 = nominal data, 1 to 8 = bad data record, 9 = no data
#       status_10 varchar(1),
#       -- integral proton flux greater than 10MeV
#       ipf_gt_10 numeric,
#       status_30 varchar(1),
#       -- integral proton flux greater than 30MeV
#       ipf_gt_30 numeric

    set duration_s "3600"
    
    foreach line $data1_list {
        # parse time
        if { [string length $line ] > 67 } {
            set yyyy [string range $line 0 3]
            set mm [string range $line 5 6]
            set dd [string range $line 8 9]
            set hour [string range $line 12 13]
            set min [string range $line 14 15]
            
            set time_utc "${hour}:${min}"
            set date "${yyyy}-${mm}-${dd}"

            set s10 [string range $line 38 38]
            set i10 [string trim [string range $line 40 50]]
            set s30 [string range $line 55 55]
            set i30 [string trim [string range $line 57 67]]
            set new_line_list [list $date $time_utc $duration_s $s10 $i10 $s30 $i30]
            
            lappend data2_lists $new_line_list
        } else {
            if { [string length $line] > 10 } {
                set maybe_data_p 1
                if { $maybe_data_p } {
                    puts "rejected -->'${line}'"
                }
                # puts "rejected '[string range $line 0 20]..[string range $line end-9 end]'"
            }
        }

    }
    puts "[llength $data2_lists] points"

    set fileId [open $newfilename w]    
    foreach row_list $data2_lists {
        set row [join $row_list ";"]
        #	puts $row
        puts $fileId $row
    }
    close $fileId
    puts "${newfilename} created."
}


proc ace_swepam_1h_to_dat { } {
    # ace_mag_1h
    # ace_sis_1h
    # ace_swepam_1h
    # ace_epam_1h
    # ace_loc_1h

    set oldfilename "/home/beta/so-corona-hole/sohoftp.nascom.nasa.gov/all_swepam_1h.txt"
    set newfilename "ace_swepam_1h.dat"
    set data_txt ""
    #  cfcount = file counter
    set cfcount 1
    set fileId [open $oldfilename r]
    puts "reading."
    while { ![eof $fileId] } {
        #  Read entire file. 
        append data_txt [read $fileId]
        puts -nonewline "."
    }
    close $fileId
    # get rid of extra spaces and all EOLs
    # create a new line for each table row
    #  split is unable to split lines consistently with \n or \r
    #  so, splitting by everything, and recompiling each line of file.
    # splitting by end-of-line
    set data1_list [split $data_txt "\n"]

    # data file is fixed-width format
    set data2_lists [list ]
#       -- yyyy-mm-dd
#       date date,
#       -- hh::mm
#       time_utc time without time zone,
#       -- seconds
#       duration_s integer,
#       --  Status(S): 0 = nominal data, 1 to 8 = bad data record, 9 = no data
#       status varchar(1),
#       proton_density numeric,
#       bulk_speed numeric,
#       -- ion temperature
#       ion_temp numeric

    set duration_s "3600"
    
    foreach line $data1_list {
        # parse time
        if { [string length $line ] > 71 } {
            set yyyy [string range $line 0 3]
            set mm [string range $line 5 6]
            set dd [string range $line 8 9]
            set hour [string range $line 12 13]
            set min [string range $line 14 15]
            
            set time_utc "${hour}:${min}"
            set date "${yyyy}-${mm}-${dd}"

            set status [string range $line 36 36]
            set pd [string trim [string range $line 38 47]]
            set bs [string trim [string range $line 49 58]]
            set it [string trim [string range $line 60 71]]

            set new_line_list [list $date $time_utc $duration_s $status $pd $bs $it]
            
            lappend data2_lists $new_line_list
        } else {
            if { [string length $line] > 10 } {
                set maybe_data_p 1
                if { $maybe_data_p } {
                    puts "rejected -->'${line}'"
                }
                # puts "rejected '[string range $line 0 20]..[string range $line end-9 end]'"
            }
        }

    }
    puts "[llength $data2_lists] points"

    set fileId [open $newfilename w]    
    foreach row_list $data2_lists {
        set row [join $row_list ";"]
        #	puts $row
        puts $fileId $row
    }
    close $fileId
    puts "${newfilename} created."
}


proc ace_epam_1h_to_dat { } {
    # ace_mag_1h
    # ace_sis_1h
    # ace_swepam_1h
    # ace_epam_1h
    # ace_loc_1h

    set oldfilename "/home/beta/so-corona-hole/sohoftp.nascom.nasa.gov/all_epam_1h.txt"
    set newfilename "ace_epam_1h.dat"
    set data_txt ""
    #  cfcount = file counter
    set cfcount 1
    set fileId [open $oldfilename r]
    puts "reading."
    while { ![eof $fileId] } {
        #  Read entire file. 
        append data_txt [read $fileId]
        puts -nonewline "."
    }
    close $fileId
    # get rid of extra spaces and all EOLs
    # create a new line for each table row
    #  split is unable to split lines consistently with \n or \r
    #  so, splitting by everything, and recompiling each line of file.
    # splitting by end-of-line
    set data1_list [split $data_txt "\n"]

    # data file is fixed-width format
    set data2_lists [list ]
#       -- yyyy-mm-dd
#       date date,
#       -- hh::mm
#       time_utc time without time zone,
#       -- seconds
#       duration_s integer,
#       -- Electron Status(S): 0 = nominal, 4,6,7,8 = bad data, unable to process, 9 = no data
#       e_status varchar(1),
#       -- values are Differential Flux:
#       electron_38_to_53 numeric,
#       electron_175_to_315 numeric,
#       -- proton status
#       p_status varchar(1),
#       -- 47 to 68
#       proton_58 numeric,
#       -- 175 to 315
#       proton_155 numeric,
#       -- 310 to 580
#       proton_445 numeric,
#       -- 795 to 1193
#       proton_644 numeric,
#       -- 1060 to 1900
#       proton_1480 numeric,
#       -- anistropy index
#       anistropy_idx numeric

    set duration_s "3600"
    
    foreach line $data1_list {
        # parse time
        if { [string length $line ] > 114 } {
            set yyyy [string range $line 0 3]
            set mm [string range $line 5 6]
            set dd [string range $line 8 9]
            set hour [string range $line 12 13]
            set min [string range $line 14 15]
            
            set time_utc "${hour}:${min}"
            set date "${yyyy}-${mm}-${dd}"

            set e_status [string range $line 34 34]
            set e46 [string trim [string range $line 36 44]]
            set e245 [string trim [string range $line 46 54]]
            set p_status [string range $line 57 57]
            set p58 [string trim [string range $line 59 67]]
            set p155 [string trim [string range $line 69 77]]
            set p455 [string trim [string range $line 79 87]]
            set p644 [string trim [string range $line 89 97]]
            set p1480 [string trim [string range $line 99 107]]
            set anti [string trim [string range $line 109 114]]

            set new_line_list [list $date $time_utc $duration_s $e_status $e46 $e245 $p_status $p58 $p155 $p455 $p644 $p1480 $anti]
            
            lappend data2_lists $new_line_list
        } else {
            if { [string length $line] > 10 } {
                set maybe_data_p 1
                if { $maybe_data_p } {
                    puts "rejected -->'${line}'"
                }
                # puts "rejected '[string range $line 0 20]..[string range $line end-9 end]'"
            }
        }

    }
    puts "[llength $data2_lists] points"

    set fileId [open $newfilename w]    
    foreach row_list $data2_lists {
        set row [join $row_list ";"]
        #	puts $row
        puts $fileId $row
    }
    close $fileId
    puts "${newfilename} created."
}


proc ace_loc_1h_to_dat { } {
    # ace_mag_1h
    # ace_sis_1h
    # ace_swepam_1h
    # ace_epam_1h
    # ace_loc_1h

    set oldfilename "/home/beta/so-corona-hole/sohoftp.nascom.nasa.gov/all_loc_1h.txt"
    set newfilename "ace_loc_1h.dat"
    set data_txt ""
    #  cfcount = file counter
    set cfcount 1
    set fileId [open $oldfilename r]
    puts "reading."
    while { ![eof $fileId] } {
        #  Read entire file. 
        append data_txt [read $fileId]
        puts -nonewline "."
    }
    close $fileId
    # get rid of extra spaces and all EOLs
    # create a new line for each table row
    #  split is unable to split lines consistently with \n or \r
    #  so, splitting by everything, and recompiling each line of file.
    # splitting by end-of-line
    set data1_list [split $data_txt "\n"]

    # data file is fixed-width format
    set data2_lists [list ]
#       -- yyyy-mm-dd
#       date date,
#       -- hh::mm
#       time_utc time without time zone,
#       -- seconds, refers to change in time per data point
#       duration_s integer,
#       x_gse numeric,
#       y_gse numeric,
#       z_gse numeric

    set duration_s "3600"
    
    foreach line $data1_list {
        # parse time
        if { [string length $line ] > 59 } {
            set yyyy [string range $line 0 3]
            set mm [string range $line 5 6]
            set dd [string range $line 8 9]
            set hour [string range $line 12 13]
            set min [string range $line 14 15]
            
            set time_utc "${hour}:${min}"
            set date "${yyyy}-${mm}-${dd}"

            set x [string trim [string range $line 33 41]]
            set y [string trim [string range $line 43 50]]
            set z [string trim [string range $line 52 59]]

            set new_line_list [list $date $time_utc $duration_s $x $y $z]
            
            lappend data2_lists $new_line_list
        } else {
            if { [string length $line] > 10 } {
                set maybe_data_p 1
                if { $maybe_data_p } {
                    puts "rejected -->'${line}'"
                }
                # puts "rejected '[string range $line 0 20]..[string range $line end-9 end]'"
            }
        }

    }
    puts "[llength $data2_lists] points"

    set fileId [open $newfilename w]    
    foreach row_list $data2_lists {
        set row [join $row_list ";"]
        #	puts $row
        puts $fileId $row
    }
    close $fileId
    puts "${newfilename} created."
}



proc tromsoe_mag_to_dat { } {
    set month_list [list 01 02 03 04 05 06 07 08 09 10 11 12]
    set year_list [list 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015]
    set hour_list [list 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23]
    set hour_last_list [list 14 18 22 26 30 34 38 42 46 50 54 58 62 66 70 74 78 82 86 90 94 98 102 106]
    # first is 2 less than last

    set newfilename "tromsoe-mag.dat"
    set data_final_lists [list ]
    set min "59"
    set duration_s "3600"
    foreach year $year_list {
        foreach month $month_list {
            set data_txt ""
            set oldfilename "/home/beta/so-corona-hole/flux.phys.uit.no/cgi-bin/HistActIx.cgi\?typ\=Ascii\&site\=tro2a\&month\=${month}\&year\=${year}\&ret\=unix\&submit\=submit"
            set inputId [open $oldfilename r]
            puts "reading ${oldfilename}..."
            while { ![eof $inputId] } {
                #  Read entire file. 
                append data_txt [read $inputId]
                puts -nonewline "."
            }
            close $inputId
            # splitting by end-of-line
            set data1_list [split $data_txt "\n"]

            #  cfcount = file counter
            set cfcount 1
            # data file is fixed-width format
            foreach line $data1_list {
                # parse time
                set dd [string range $line 0 1]
                if { [string length $line ] > 106 && $dd ne "DD" } {
                    set yyyy [string range $line 6 9]
                    set mm [string range $line 3 4]
                    #set dd \[string range $line 0 1\]
                    set hour_i 0
                    foreach hour $hour_list {
                        set last_i [lindex $hour_last_list $hour_i]
                        set first_i [expr { $last_i - 2 } ]

                        set time_utc "${hour}:${min}"
                        set date "${yyyy}-${mm}-${dd}"
                    
                        set x [string trim [string range $line $first_i $last_i]]
                        incr hour_i
                    }
                    
                    set new_line_list [list $date $time_utc $duration_s $x]
                    incr cfcount
                    lappend data_final_lists $new_line_list
                } else {
                    if { [string length $line] > 10 } {
                        set maybe_data_p 1
                        if { $line eq "Activity index for Tromso" || $dd eq "DD" } {
                            set maybe_data_p 0
                        }
                        if { $line eq "The activity index is the absolute mean deviation from last 24 hrs mean H" } {
                            set maybe_data_p 0
                        }
                        if { $maybe_data_p } {
                            puts "rejected -->'${line}'"
                        }
                        # puts "rejected '[string range $line 0 20]..[string range $line end-9 end]'"
                    }
                }
                
            }
            puts "${cfcount} points for ${year}-${month}."
        }
    }
            
            
    set outputId [open $newfilename w]    
    foreach row_list $data_final_lists {
        set row [join $row_list ";"]
        #	puts $row
        puts $outputId $row
    }
    
    close $outputId
    puts "${newfilename} with [llength $data_final_lists] points created."
}
