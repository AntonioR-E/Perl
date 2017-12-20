#!/usr/bin/perl
# Perl Lab 3
# Antonio Rodriguez Esquire
# CITE 30153
# Oct 19, 2017

use 5.18.0;
use warnings;
use strict;
use List::Util qw[min max];  # min max of array



my @GGAtimes;
my @GGAlat;
my @GGAlong;
my @GGAsat;
my @GSAsat;
my @GSVsatNum;
my @satPRNSRN;
my $tempString;
my @sumLat=0;
my @avgLat;
my @sumLong=0;
my @avgLong;
my @prn;
my @snr;
my $prnMinMax;


foreach my $line (<STDIN>) {

    # Read input and chomp line

    chomp( $line );

    if ($line =~ /^\$GPGGA/) {
          # put time into array-@GGAtimes
            if ($line =~ /\d{6}/g)
            {
                my $final = time_format($&);  # sub the time regex
                push @GGAtimes, $final;         # push into array after formated  to print to string
            }
            # put lat in to array-@GGAlat
            if ($line =~ /,\d{4}\.?\d*,[a-zA-Z]/)
            {
                my $lat = lat_format($&);    # sub lat format
                push @GGAlat, $lat;             # push lat into array to print string

                my @latSplit = (split /,/,$line);
                push @sumLat,$latSplit[2];              # sumLat is for collecting latitude in order to do the sum


            }
            # put long into array-@GGAlong
            if ($line =~ /,(\d{5}\.\d*),([a-z,A-Z])/g)
            {
                my $long = long_format($&);
                push @GGAlong, $long;           # sub long format in order to print to string

                my @longSplit = (split/,/,$line);
                push @sumLong, $longSplit[4];       # collecting long. to get sum


            }
            # put number of sat into array-@GGAsat (fix)
            if ($line =~ /,\d,\d+,/)
            {
                my @sat = (split /,/, $&);
                push @GGAsat, $sat[2];              # Getting sat number from GGA
            }

    }
    if ($line =~ /^\$GPGSA/) {
        # GSA sat count
        my @delm = (split /,/, $line);
        my $string;


            for (my $i = 0; $i < $#delm; $i++) {
                if ($delm[$i] =~ /^\d{2}$/) {
                    $string = $string." $delm[$i]";

                }

            }
        my @numCount = (split /\s/, $string);
        shift @numCount;                 ## getting rid of extra space at the beginning of the array? ¯\_(ツ)_/¯
        my $finalCnt = scalar @numCount;
        my $finalStr = "$finalCnt   PRN Satellites: @numCount";   # satellite count and PRN
        push @GSAsat, $finalStr;                    # push to print string later


    }
    if ($line =~ /^\$GPGSV,\d,1/) {
        my @firstMatch = (split/,/,$line);
        push @GSVsatNum , $firstMatch[3];
        my @match =($line =~ m/\d{2},\d{2},\d{3},\d{2}+/g);  # getting prn and srn

        for (my $i = 0; $i < ($#match+1) ; $i++) {
            my @new = (split /,/, $match[$i]);
            if ($new[0]<33) {                               # Satellites  1 - 32
                $tempString = $tempString."\n\t\tSatellite: $new[0] SNR: $new[3]";  # getting prn and snr line
                push @prn, $new[0];         #  prn collection for part 2
                push @snr, $new[3];         # snr collection for part 2 min - max
            }

        }




    }
    if ($line =~ /^\$GPGSV,2,2/) {     # same as above for second line of GSV

        my @match =($line =~ m/\d{2},\d{2},\d{3},\d{2}+/g);

        for (my $i = 0; $i < ($#match+1) ; $i++) {
            my @new = (split /,/, $match[$i]);
            if ($new[0]<33) {
                $tempString = $tempString."\n\t\tSatellite: $new[0] SNR: $new[3]";  # carry over from GSV line 2
                push @prn, $new[0];
                push @snr, $new[3];
            }

        }

        push @satPRNSRN, $tempString;
        $tempString="";         # reset temp string


    }
    if ($line =~ /^\$GPGSV,3,2/) {     # same as above for second line of GSV

        my @match =($line =~ m/\d{2},\d{2},\d{3},\d{2}+/g);

        for (my $i = 0; $i < ($#match+1) ; $i++) {
            my @new = (split /,/, $match[$i]);
            if ($new[0]<33) {
                $tempString = $tempString."\n\t\tSatellite: $new[0] SNR: $new[3]";  # carry over from GSV line 2
                push @prn, $new[0];
                push @snr, $new[3];
            }

        }

    }

    if ($line =~ /^\$GPGSV,3,3/) {

        my @match =($line =~ m/\d{2},\d{2},\d{3},\d{2}+/g);

        for (my $i = 0; $i < ($#match+1) ; $i++) {
            my @new = (split /,/, $match[$i]);
            if ($new[0]<33) {
                $tempString = $tempString."\n\t\tSatellite: $new[0] SNR: $new[3]";  # carry over from GSV line 2
                push @prn, $new[0];
                push @snr, $new[3];
            }

        }
        push @satPRNSRN, $tempString;
        $tempString="";         # reset temp string
    }

    
}
sub time_format{    # set time format to HH:MM:SS

    my @time = (split //, shift);

    my $hours = $time[0].$time[1];
    my $min = $time[2].$time[3];
    my $sec = $time[4].$time[5];

    return "$hours:$min:$sec";

}
sub lat_format {   # set lat format to deg min' sec" direction

    my @lat = (split /,(\d*)(\.\d*),([a-zA-Z])/, shift);
    my @dm = (split // , $lat[1]);

    my $deg = $dm[0].$dm[1];
    my $min = $dm[2].$dm[3];
    my $sec = $lat[2] * 60;      # conversion to get right format
    my $comp = $lat[3];

    return "$deg° $min' $sec\", $comp";

}
sub avg_lat_format {   # get avg lat

    my @lat = (split /(\d*)(\.\d*)/, shift);
    my @dm = (split // , $lat[1]);

    my $deg = $dm[0].$dm[1];
    my $min = $dm[2].$dm[3];
    my $sec = sprintf("%.3f",($lat[2] * 60)); # format 3 decimal points


    return "$deg° $min' $sec\"";

}
sub long_format{  # get long format

    my @long = (split /,(\d*)(\.\d*),([a-zA-Z])/, shift);
    my @dm = (split // , $long[1]);
    my $deg = $dm[0].$dm[1].$dm[2];
    my $min = $dm[3].$dm[4];
    my $sec = $long[2] * 60;     # get conversion
    my $comp = $long[3];

    return "$deg° $min' $sec\", $comp";

}
sub avg_long_format{  # get avg for long

    my @long = (split /(\d*)(\.\d*)/, shift);

    my @dm = (split // , $long[1]);

    my $deg = $dm[0].$dm[1].$dm[2];
    my $min = $dm[3].$dm[4];
    my $sec = sprintf("%.3f",($long[2] * 60));  # format 3 decimal points



    return "$deg° $min' $sec\"";

}


sub avg {

    my $sum = shift;   # current sum input
    my $avg = $sum/30;  # 30 seconds
    return $avg;

}
sub long_avg {

    my $sum = shift;
    my $avg = $sum/30;
   my @finalavg = (split /\./,$avg);
    my $first= sprintf("%05d",$finalavg[0]);   # add leading zero if needed or lost in average
    my $second = $finalavg[1];          # split into two parts to avoid change in number after format for leading zero

    my $finalStrg = "$first.$second";  # concatinate

    return $finalStrg;

}

# creating arrays to collect each snr for the prn sat

my @p1;my @p2; my @p3; my @p4; my @p5; my @p6; my @p7; my @p8;my @p9;my @p10;
my @p11; my @p12; my @p13; my @p14; my @p15; my @p16; my @p17; my @p18; my @p19;
my @p20; my @p21; my @p22; my @p23; my @p24; my @p25; my @p26; my @p27; my @p28; my @p29;
my @p30; my @p31; my @p32;

sub interval {     # collecting the 30 second interval  interval(+30) added after every interval
    my $num = shift;  # first shift 0++ until n=30 then (n + 30)

    my $sumla =0;
    my $sumlo =0;


        for (my $i = $num; $i < ($num + 30); $i++) {
            # num changed to +30 every interval to pull from current 30 sec interval
            if (!$sumLat[$i]) {

            }else {
                $sumla = $sumLat[$i] + $sumla;
                $sumlo = $sumLong[$i] + $sumlo;
            }


            if ($prn[$i] == 1) {# checking prn and adding srn to @p(n) array to get min and max foreach prn sat
                push @p1, $snr[$i];
            }
            if ($prn[$i] == 2) {
                push @p2, $snr[$i];
            }
            if ($prn[$i] == 3) {
                push @p3, $snr[$i];
            }
            if ($prn[$i] == 4) {
                push @p4, $snr[$i];
            }
            if ($prn[$i] == 5) {
                push @p5, $snr[$i];
            }
            if ($prn[$i] == 6) {
                push @p6, $snr[$i];
            }
            if ($prn[$i] == 7) {
                push @p7, $snr[$i];
            }
            if ($prn[$i] == 8) {
                push @p8, $snr[$i];
            }
            if ($prn[$i] == 9) {
                push @p9, $snr[$i];
            }
            if ($prn[$i] == 10) {
                push @p10, $snr[$i];
            }
            if ($prn[$i] == 11) {
                push @p11, $snr[$i];
            }
            if ($prn[$i] == 12) {
                push @p12, $snr[$i];
            }
            if ($prn[$i] == 13) {
                push @p13, $snr[$i];
            }
            if ($prn[$i] == 14) {
                push @p14, $snr[$i];
            }
            if ($prn[$i] == 15) {
                push @p15, $snr[$i];
            }
            if ($prn[$i] == 16) {
                push @p16, $snr[$i];
            }
            if ($prn[$i] == 17) {
                push @p17, $snr[$i];
            }
            if ($prn[$i] == 18) {
                push @p18, $snr[$i];
            }
            if ($prn[$i] == 19) {
                push @p19, $snr[$i];
            }
            if ($prn[$i] == 20) {
                push @p20, $snr[$i];
            }
            if ($prn[$i] == 21) {
                push @p21, $snr[$i];
            }
            if ($prn[$i] == 22) {
                push @p22, $snr[$i];
            }
            if ($prn[$i] == 23) {
                push @p23, $snr[$i];
            }
            if ($prn[$i] == 24) {
                push @p24, $snr[$i];
            }
            if ($prn[$i] == 25) {
                push @p25, $snr[$i];
            }
            if ($prn[$i] == 26) {
                push @p26, $snr[$i];
            }
            if ($prn[$i] == 27) {
                push @p27, $snr[$i];
            }
            if ($prn[$i] == 28) {
                push @p28, $snr[$i];
            }
            if ($prn[$i] == 29) {
                push @p29, $snr[$i];
            }
            if ($prn[$i] == 30) {
                push @p30, $snr[$i];
            }
            if ($prn[$i] == 31) {
                push @p31, $snr[$i];
            }
            if ($prn[$i] == 32) {
                push @p32, $snr[$i];
            }

        }

        # checking to see if @p(n) is true
        # if true, find min - max and set temp string for interval
        if (@p1) {
            my $min = min(@p1);
            my $max = max(@p1);
            $prnMinMax = $prnMinMax . "\t\tPRN: 1 SNRMin: $min  SNRMax: $max\n";
        }
        if (@p2) {
            my $min = min(@p2);
            my $max = max(@p2);
            $prnMinMax = $prnMinMax . "\t\tPRN: 2 SNRMin: $min  SNRMax: $max\n";
        }
        if (@p3) {
            my $min = min(@p3);
            my $max = max(@p3);
            $prnMinMax = $prnMinMax . "\t\tPRN: 3 SNRMin: $min  SNRMax: $max\n";
        }
        if (@p4) {
            my $min = min(@p4);
            my $max = max(@p4);
            $prnMinMax = $prnMinMax . "\t\tPRN: 4 SNRMin: $min  SNRMax: $max\n";
        }
        if (@p5) {
            my $min = min(@p5);
            my $max = max(@p5);
            $prnMinMax = $prnMinMax . "\t\tPRN: 5 SNRMin: $min  SNRMax: $max\n";
        }
        if (@p6) {
            my $min = min(@p6);
            my $max = max(@p6);
            $prnMinMax = $prnMinMax . "\t\tPRN: 6 SNRMin: $min  SNRMax: $max\n";
        }
        if (@p7) {
            my $min = min(@p7);
            my $max = max(@p7);
            $prnMinMax = $prnMinMax . "\t\tPRN: 7 SNRMin: $min  SNRMax: $max\n";
        }
        if (@p8) {
            my $min = min(@p8);
            my $max = max(@p8);
            $prnMinMax = $prnMinMax . "\t\tPRN: 8 SNRMin: $min  SNRMax: $max\n";
        }
        if (@p9) {
            my $min = min(@p9);
            my $max = max(@p9);
            $prnMinMax = $prnMinMax . "\t\tPRN: 9 SNRMin: $min  SNRMax: $max\n";

        }
        if (@p10) {
            my $min = min(@p9);
            my $max = max(@p9);
            $prnMinMax = $prnMinMax . "\t\tPRN: 10 SNRMin: $min  SNRMax: $max\n";
        }
        if (@p11) {
            my $min = min(@p11);
            my $max = max(@p11);
            $prnMinMax = $prnMinMax . "\t\tPRN: 11 SNRMin: $min  SNRMax: $max\n";
        }
        if (@p12) {
            my $min = min(@p12);
            my $max = max(@p12);
            $prnMinMax = $prnMinMax . "\t\tPRN: 12 SNRMin: $min  SNRMax: $max\n";
        }
        if (@p13) {
            my $min = min(@p13);
            my $max = max(@p13);
            $prnMinMax = $prnMinMax . "\t\tPRN: 13 SNRMin: $min  SNRMax: $max\n";
        }
        if (@p14) {
            my $min = min(@p14);
            my $max = max(@p14);
            $prnMinMax = $prnMinMax . "\t\tPRN: 14 SNRMin: $min  SNRMax: $max\n";
        }
        if (@p15) {
            my $min = min(@p15);
            my $max = max(@p15);
            $prnMinMax = $prnMinMax . "\t\tPRN: 15 SNRMin: $min  SNRMax: $max\n";
        }
        if (@p16) {
            my $min = min(@p16);
            my $max = max(@p16);
            $prnMinMax = $prnMinMax . "\t\tPRN: 16 SNRMin: $min  SNRMax: $max\n";
        }
        if (@p17) {
            my $min = min(@p17);
            my $max = max(@p17);
            $prnMinMax = $prnMinMax . "\t\tPRN: 17 SNRMin: $min  SNRMax: $max\n";
        }
        if (@p18) {
            my $min = min(@p18);
            my $max = max(@p18);
            $prnMinMax = $prnMinMax . "\t\tPRN: 18 SNRMin: $min  SNRMax: $max\n";
        }
        if (@p19) {
            my $min = min(@p19);
            my $max = max(@p19);
            $prnMinMax = $prnMinMax . "\t\tPRN: 19 SNRMin: $min  SNRMax: $max\n";
        }
        if (@p20) {
            my $min = min(@p20);
            my $max = max(@p20);
            $prnMinMax = $prnMinMax . "\t\tPRN: 20 SNRMin: $min  SNRMax: $max\n";
        }
        if (@p21) {
            my $min = min(@p21);
            my $max = max(@p21);
            $prnMinMax = $prnMinMax . "\t\tPRN: 21 SNRMin: $min  SNRMax: $max\n";
        }
        if (@p22) {
            my $min = min(@p22);
            my $max = max(@p22);
            $prnMinMax = $prnMinMax . "\t\tPRN: 22 SNRMin: $min  SNRMax: $max\n";
        }
        if (@p23) {
            my $min = min(@p23);
            my $max = max(@p23);
            $prnMinMax = $prnMinMax . "\t\tPRN: 23 SNRMin: $min  SNRMax: $max\n";
        }
        if (@p24) {
            my $min = min(@p24);
            my $max = max(@p24);
            $prnMinMax = $prnMinMax . "\t\tPRN: 24 SNRMin: $min  SNRMax: $max\n";
        }
        if (@p25) {
            my $min = min(@p25);
            my $max = max(@p25);
            $prnMinMax = $prnMinMax . "\t\tPRN: 25 SNRMin: $min  SNRMax: $max\n";
        }
        if (@p26) {
            my $min = min(@p26);
            my $max = max(@p26);
            $prnMinMax = $prnMinMax . "\t\tPRN: 26 SNRMin: $min  SNRMax: $max\n";
        }
        if (@p27) {
            my $min = min(@p27);
            my $max = max(@p27);
            $prnMinMax = $prnMinMax . "\t\tPRN: 27 SNRMin: $min  SNRMax: $max\n";
        }
        if (@p28) {
            my $min = min(@p28);
            my $max = max(@p28);
            $prnMinMax = $prnMinMax . "\t\tPRN: 28 SNRMin: $min  SNRMax: $max\n";
        }
        if (@p29) {
            my $min = min(@p29);
            my $max = max(@p29);
            $prnMinMax = $prnMinMax . "\t\tPRN: 29 SNRMin: $min  SNRMax: $max\n";
        }
        if (@p30) {
            my $min = min(@p30);
            my $max = max(@p30);
            $prnMinMax = $prnMinMax . "\t\tPRN: 30 SNRMin: $min  SNRMax: $max\n";
        }
        if (@p31) {
            my $min = min(@p31);
            my $max = max(@p31);
            $prnMinMax = $prnMinMax . "\t\tPRN: 31 SNRMin: $min  SNRMax: $max\n";
        }
        if (@p32) {
            my $min = min(@p32);
            my $max = max(@p32);
            $prnMinMax = $prnMinMax . "\t\tPRN: 32 SNRMin: $min  SNRMax: $max\n";
        }



    my $finalla = avg($sumla);     # format and get avg lat for current interval
    my $finallo = long_avg($sumlo);  # format and long avg for current interval

    push @avgLat, $finalla;     # collecting sting to print
    push @avgLong, $finallo;
}



   # first 10 seconds of data
for (my $i = 0; $i<10; $i++ ) {

    say "\nTime: \t\t $GGAtimes[$i]";
    say "Latitude: \t $GGAlat[$i]";
    say "Longitude: \t $GGAlong[$i]";
    say "Number of Satellites Used for Fix: $GGAsat[$i]";
    say "Satellites in view $GSVsatNum[$i]";
    say "PRN & SNR: \t $satPRNSRN[$i]";

}

my $length = $#GGAtimes;
my $numOfIntvl = $length/30;
my $inter = 0;
my $timeInt = 30;
my $count=1;  # counting intervals
say "----------------------------------------------------------------------------------------\n";
for (my $i = 0 ; $i< $numOfIntvl ; $i++ ) {
    interval($inter);  # start with zero and then add 30
    $inter = $i + 30;


    my $lat = avg_lat_format($avgLat[$i]);
    my $long = avg_long_format($avgLong[$i]);



    if ($GGAtimes[$timeInt]) {
                # error handling if == 30 second interval print
        my $aLat = sprintf("%.6f",$avgLat[$i]);
        my $aLong = sprintf("%.6f",$avgLong[$i]);
        say "CDT = $GGAtimes[$timeInt]\t\t\t Avg Lat = $aLat \t\tAvg Long = $aLong";
    }
    else{
                # error less than 30 seconds. print what is left over until empty
        my $aLat = sprintf("%.6f",$avgLat[$i]);
        my $aLong = sprintf("%.6f",$avgLong[$i]);
        say "CDT = $GGAtimes[$length]\t\t\t Avg Lat = $aLat \t\tAvg Long = $aLong";
    }
    say "Interval: $count \t\t\t Avg Lat = $lat\tAvg Long = $long ";

    $timeInt = $timeInt + 30;
    say "Satellite Information:";
    say "$prnMinMax";
    say "----------------------------------------------------------------------------------------\n";
    $prnMinMax = "";  # reset temp string for interval  prn min max string
    $count++;

}

my $finalSumEndLAT=0;
my $finalSumEndLong=0;
for (my $i = 0; $i<($#sumLat+1) ; $i++ ){

        $finalSumEndLAT = $sumLat[$i]+$finalSumEndLAT;
        $finalSumEndLong = $sumLong[$i]+$finalSumEndLong;

}
shift @sumLat;
shift @sumLong;
my $finalAvgLAT = avg($finalSumEndLAT);
my $finalAvgLONG = long_avg($finalSumEndLong);
my $doneLat = avg_lat_format($finalAvgLAT);
my $doneLong = avg_long_format($finalAvgLONG);
my $doneMinLat = min (@sumLat);
my $doneMaxLat = max (@sumLat);
my $doneMinLong = min (@sumLong);
my $doneMaxLong = max (@sumLong);
$doneMinLat = avg_lat_format ($doneMinLat);
$doneMaxLat = avg_lat_format ($doneMaxLat);
$doneMinLong = avg_long_format ($doneMinLong);
$doneMaxLong = avg_long_format ($doneMaxLong);

say "Final report: \n";
say "Average Latitude: $doneLat \t Average Longitude: $doneLong";
say "Min Latitude: $doneMinLat \t\t Max Latitude: $doneMaxLat";
say "Min Longitude: $doneMinLong \t Max Longitude: $doneMaxLong";

