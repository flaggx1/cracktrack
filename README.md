## *CrackTrack* ##

**CrackTrack** is a hashcat potfile monitoring program that prints cracking statistics for time periods. It prints cracks per minute, hour, and day based on the hashcat potfile or outfile. The current time period and a total average is printed. Supports the use of one or more leftlists to calculate statistics on only desired hashes. No interpolation is performed, and statistics are printed only after at least one time cycle completes. Supports time interval as well as keyboard press for status print.

Note that hashcat itself does calculate and output cracks over time statistics, and in basic mode this program duplicates that functionality.

### Flags ###
```
-p   -potfile    Potfile or outfile to be monitored.
-l   -leftlist   Monitor only cracks from leftlist. Supports multiple leftlists.
-i   -interval   Output interval in minutes. Default is 15 minutes.
-u   -unique     Cracks are only counted once. Increases memory usage.
-t   -time       Print current date and time in output.
```
### Examples ###
```
## Monitor all cracks
cracktrack.pl -p hashcat.potfile

## Monitor only cracks from specified leftlist
cracktrack.pl -p hashcat.potfile -t -l hashes.left

## Multiple leftlists
cracktrack.pl -p hashcat.potfile -t -l hashes.left -l hashes2.left

## Print time in output and change print interval to 60 minutes
cracktrack.pl -p hashcat.potfile -t -i 60
```

### Notes ###
* Multiple leftlists can be specified: -l 'list1' -l 'list2' -l 'list3'
* Ensure you have enough memory for leftlists, they are stored in a hash.
* Stats are calculated for timeframes only once per cycle. No interpolation.
* Hashes are all lowercased (only in memory) for comparison purposes.
* Unique can be utilized when duplicate hashes are expected in potfile.
* Press any key to print the status display screen. Interval still prints.
* Based on Virodoran idea to monitor cracks relating to specific leftlists.

### License ###

**CrackTrack** is licensed under the MIT license.
