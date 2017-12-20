#!/usr/bin/perl

use 5.18.0;
use strict;
use warnings FATAL => 'all';
use List::MoreUtils qw(uniq);

my $file="";


    sub words_with_count() {
        my %count;
        my @arry;

        open (my $fh, '<', $file) or die "Could not open '$file' $!";
        while (my $line = <$fh>) {
            chomp $line;

            foreach my $str (split /[:?,.\s\/]+/, lc $line) {
                $count{$str}++;
            }
        }

        my $ref = \%count;
        foreach my $word (sort keys %{$ref}) {
            push @arry, "$word: ${$ref}{$word}    ";
            #say "$word: ${$ref}{$word}    ";

        }

        my $arCount = $#arry;
        for (my $a = 0; $a < $arCount; $a++) {
            printf $arry[$a];
            $a++;
            print $arry[$a];
            $a++;
            print $arry[$a];
            $a++;
            print $arry[$a];
            $a++;
            print "$arry[$a]\n";

        }
    }


    sub line_count_words {
        my %hash;
        my $counter = 0;
        my $wordCount = 0;
        my $lineUniq;

        open (my $fh, '<', $file) or die "Cannot open file:  $!";

        while (my $line = <$fh>) {

            chomp $line;
            $hash{$line} = $counter++;

            my @arry;

            foreach my $str (split /[:?,.\s\/]+/, lc $line) {
                $hash{$str}++;
                $wordCount++;

                push(@arry, $str);
                $lineUniq = uniq(@arry);

            }

            say "Line $counter: $wordCount words $lineUniq unique words";
            $wordCount = 0;
            $lineUniq = 0;

        }

    }
    sub totals {
        my %count;
        my $uniq = 0;
        my $totalWords = 0;

        open (my $fh, '<', $file) or die "Could not open '$file' $!";
        while (my $line = <$fh>) {
            chomp $line;
            foreach my $str (split /[:?,.\s\/]+/, lc $line) {
                $count{$str}++;
                $totalWords++;

            }
        }

        my $ref = \%count;
        foreach my $word (sort keys %{$ref}) {
            $uniq++
        }
        say "Total number of words found in the file:  $totalWords";
        say "Total number of unique words found in the file: $uniq and they are:";
    }


my $superVar=1;

while ($superVar >0) {
    print "Enter name of file:  ";
    $file = <STDIN>;
    chomp $file;

    if ($file eq 'quit') {
        $superVar =0;
    }
    else {
        say "\n";
        print "Summary of file $file: \n\n";
        line_count_words;
        say "\n";
        totals;
        say "\n";
        words_with_count;
        say "\n";

    }

}















