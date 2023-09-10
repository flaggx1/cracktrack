#!/usr/bin/env perl

## Author: Flagg [Hashmob], 2023
## Name: CrackTrack 0.9.1

use strict;
use warnings;
use Getopt::Long;
use threads;
use threads::shared;
use Term::ANSIColor qw(:constants);

## Define options for program
my $potfile_path;
my @leftlist_paths;
my $print_interval = 1;
my $time_enable = 0;
GetOptions(
  "help|h|?" => sub { help(); },
  "p|potfile=s" => \$potfile_path,
  "l|leftlist=s" => \@leftlist_paths,
  "i|interval=n" => \$print_interval,
  "t|time" => \$time_enable)
or help();
help() unless $potfile_path;

## Define shared variable to be used in main program and status thread
my $crack_count:shared = 0;

## Process leftlists and load into memory hash.
my %leftlist_hashes = %{load_leftlists(@leftlist_paths)};

## Tracks new cracks by minute, hour, and day. Data is calculated for current time period and an average.
my $status_thread = threads->create(\&status_thread);

## Detach thread from main program so it runs independently
$status_thread->detach();

## Main loop, reads new lines from potfile and adds to cracks counter
monitor_potfile($potfile_path, \%leftlist_hashes, $print_interval, $time_enable);

sub load_leftlists {
  my (@leftlist_paths) = @_;
  my %leftlist_hashes;

  foreach my $leftlist_path (@leftlist_paths) {
    chomp $leftlist_path;
    error("Leftlist does not exist! ($leftlist_path)") unless -e $leftlist_path;
    error("Leftlist is not readable! ($leftlist_path)") unless -r $leftlist_path;
    print BOLD GREEN "Loading Leftlist: $leftlist_path", RESET, "\n";
    open(LEFTLIST, '<', $leftlist_path) or error ("Cannot open leftlist ($leftlist_path)");
    while (my $hash = <LEFTLIST>) {
      chomp $hash;
      $leftlist_hashes{lc($hash)} = 1;
    }
  }
  return \%leftlist_hashes;
}

sub monitor_potfile {
  my ($potfile_path, $leftlist_hashes, $print_interval, $time_enable) = @_;

  error("Potfile does not exist! ($potfile_path)") unless -e $potfile_path;
  error("Potfile is not readable! ($potfile_path)") unless -r $potfile_path;
  print BOLD GREEN "Monitoring Potfile: $potfile_path", RESET, "\n\n";
  open(POTFILE, '<', $potfile_path) or error("Cannot open potfile: $potfile_path");
  seek(POTFILE, 0, 2);  ## Seek to end of the file to read only new lines

  while () {
    while (my $line = <POTFILE>) {
      if (defined $line) {
        chomp $line;
        if (my ($hash) = split(/:/, $line)) {
          lock $crack_count;
          ## If leftlists were specified, search for cracked hashes and increment crack count only if matched
          if (%$leftlist_hashes) {
            if ($leftlist_hashes->{lc($hash)}) {
              $crack_count++;
            }
          }
          ## If no leftlists were specified, add all new cracks to crack count
          else {
            $crack_count++;
          }
        }
      }
    }
    sleep 1;
  }
}

sub status_thread {
  my $time = time;
  my $start_minute = $time;
  my $start_hour   = $time;
  my $start_day    = $time;
  my $start_print  = $time;
  my $cracks_average_minute = 0;
  my $cracks_average_hour   = 0;
  my $cracks_average_day    = 0;
  my $cracks_current_minute = 0;
  my $cracks_current_hour   = 0;
  my $cracks_current_day    = 0;

  my %minutes = ('count' => 0, 'cracks' => 0, 'last' => 0);
  my %hours   = ('count' => 0, 'cracks' => 0, 'last' => 0);
  my %days    = ('count' => 0, 'cracks' => 0, 'last' => 0);

  ## Main time loop
  while () {
    my $current_time = time;
    if ($current_time - $start_minute >= 60) {
      $cracks_current_minute = $crack_count - $minutes{last};
      $minutes{count}++;
      $minutes{cracks}+= $cracks_current_minute;
      $minutes{last} = $crack_count;
      $cracks_average_minute = 0; $cracks_average_minute = $minutes{cracks} / $minutes{count} if $minutes{count};
      $start_minute = $current_time;
    }
    if ($current_time - $start_hour >= 3600) {
      $cracks_current_hour = $crack_count - $hours{last};
      $hours{count}++;
      $hours{cracks}+= $cracks_current_hour;
      $hours{last} = $crack_count;
      $cracks_average_hour = 0; $cracks_average_hour = $hours{cracks} / $hours{count} if $hours{count};
      $start_hour = $current_time;
    }
    if ($current_time - $start_day >= 86400) {
      $cracks_current_day = $crack_count - $days{last};
      $days{count}++;
      $days{cracks}+= $cracks_current_day;
      $days{last} = $crack_count;
      $cracks_average_day = 0; $cracks_average_day = $days{cracks} / $days{count} if $days{count};
      $start_day = $current_time;
    }

    ## Print status message after specified interval
    if ($current_time - $start_print >= ($print_interval * 60)) {
      my $formatted_time = $time_enable ? get_current_time() . ' ' : '';
      printf("Cracks/Time %s| Current: %05.2fm %05.2fh %05.2fd | Average: %05.2fm %05.2fh %05.2fd\n",
        $formatted_time,
        $cracks_current_minute, $cracks_current_hour, $cracks_current_day,
        $cracks_average_minute, $cracks_average_hour, $cracks_average_day
      );
      $start_print = $current_time;
    }

    sleep 1;
  }
}

sub get_current_time {
    my ($sec, $min, $hour, $mday, $mon, $year) = localtime();
    $mon++;  ## Adjust month (0-based to 1-based)
    $year += 1900;  ## Adjust year (counting from 1900)

    my $formatted_time = sprintf("%04d-%02d-%02d %02d:%02d", $year, $mon, $mday, $hour, $min);
    return $formatted_time;
}

sub error {
  my $message = shift;
  die RED "Error: ", $message, RESET, "\n";
}

sub help {
  print "--CrackTrack-- by Flagg [Hashmob], 2023\n";
  print "Potfile Monitoring and Statistics\n\n";
  print "Required:\n\n";
  print "  -p   -potfile    Potfile or outfile to be monitored.\n\n";
  print "Optional:\n\n";
  print "  -l   -leftlist   Monitor only cracks from leftlist. Supports multiple leftlists.\n";
  print "  -i   -interval   Output interval in minutes. Default is 1 minute.\n";
  print "  -t   -time       Print current date and time in output.\n\n";
  print "Notes:\n\n";
  print "  -Multiple leftlists can be specified: -l 'list1' -l 'list2' -l 'list3'\n";
  print "  -Ensure you have enough memory for leftlists, they are stored in a hash.\n";
  print "  -Stats are calculated for timeframes only once per cycle. No interpolation.\n";
  print "  -Based on Virodoran idea to monitor cracks relating to specific leftlists.\n\n";
  exit;
}
