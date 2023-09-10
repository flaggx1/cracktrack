## *CrackTrack* ##

**CrackTrack** is a hashcat potfile monitoring program that prints cracking statistics for time periods. It prints cracks per minute, hour, and day based on the hashcat potfile or outfile. The current time period and a total average is printed. Supports the use of one or more leftlists to calculate statistics on only desired hashes. No interpolation is performed, and statistics are printed only after at least one time cycle completes.

### License ###

**CrackTrack** is licensed under the MIT license.

### Flags ###
```
-p   -potfile    Potfile or outfile to be monitored.
-l   -leftlist   Monitor only cracks from leftlist. Supports multiple leftlists.
-i   -interval   Output interval in seconds. Minimum is 60 seconds.
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
* Based on Virodoran idea to monitor cracks relating to specific leftlists.
