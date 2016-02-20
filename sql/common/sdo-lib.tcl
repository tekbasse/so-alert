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
puts "proc sdo_browse_images_url_list { } "
puts "proc sdo_imagename_to_params_list { imagename } "
puts "proc sdo_import_imagenames { filename } "


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

proc date_range_lister { first_yyyymmdd last_yyyymmdd } {
    # a date range builder
    # for choosing a set of dates from first to last inclusive
    set date_list [list ]
    set day_sec [expr { 24 * 60 * 60 } ]
    set first_date_sec [clock scan $first_yyyymmdd -format "%Y%m%d" ]
    set last_date_sec [clock scan $last_yyyymmdd -format "%Y%m%d" ]
    for { set i $first_date_sec} { $i <= $last_date_sec } { incr i $day_sec } {
	set date [clock format $i -format "/%Y/%m/%d/"]
	lappend date_list $date
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
		# add a default priority and notes column
		lappend data_point_list 0 ""
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
    puts "$filename has ${line_count} data points."
    puts "[llength $table_lists] data points imported."
    set newfilename "sdo-ii.dat"
    set fileId [open $newfilename w]    
    foreach row_list $table_lists {
	set row [join $row_list ";"]
	puts $row
        puts $fileId $row
    }
    close $fileId
    puts "${newfilename} created."
}
