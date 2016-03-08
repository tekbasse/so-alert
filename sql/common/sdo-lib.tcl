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
                set ee_sql "AD"
            } else {
                set ee "B.C."
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
            puts "$line_count $yyyy-$h-$dd $ee ${time_dt}"
            set date_time_s [clock scan "$yyyy-$h-$dd $ee ${time_dt}" -format "%Y-%h-%d %EE %H:%M:%S"]
            #   time_utc time without time zone,
            set t_delta [string trim [string range $line 35 40]]

            # delta_t = time_dt - time_utc  per eclipse.gsfc.nasa.gov/SEcat5/deltat.html
            set datetime_utc_s [expr { $date_time_s - $t_delta } ]
            set date [string range [clock format $datetime_utc_s -format "%Y-%m-%d %EE"] 0 end-4]
            append date $ee_sql
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
                set ee_sql "AD"
            } else {
                set ee "B.C."
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
            puts "$line_count $yyyy-$h-$dd $ee ${time_dt}"
            set date_time_s [clock scan "$yyyy-$h-$dd $ee ${time_dt}" -format "%Y-%h-%d %EE %H:%M:%S"]
            #   time_utc time without time zone,
            set t_delta [string trim [string range $line 31 35]]

            # delta_t = time_dt - time_utc  per eclipse.gsfc.nasa.gov/SEcat5/deltat.html
            set datetime_utc_s [expr { $date_time_s - $t_delta } ]
            set date [string range [clock format $datetime_utc_s -format "%Y-%m-%d %EE"] 0 end-4]
            append date $ee_sql
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
