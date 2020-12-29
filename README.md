monitorig
=========

(c) 2019 Andrew C.R. Martin
---------------------------

### WARNING!!!
### This code no longer works as Instagram now provides nothing
### for non-logged-in users!!!


Monitors an Instagram account each hour for the number of posts, 
followers and following. If no change, just prints a '.'. If an
error occurred, prints an 'X'.

Usage
-----


```
monitorig [-u=user] [-s=sleep] [-o=output] [-d]
       -u  Specify user account to monitor [andrewcrmartin]
       -s  Specify sleep time in hours [1]
       -o  Specify output file [$HOME/Dropbox/00NOTES/monitor.txt]
       -d  Debug - runs once and outputs to standard output
```


Typically you would run this with something like:

```
nohup ./monitorig.pl -u=username &> /tmp/monitorig.log &
```

