monitorig
=========

(c) 2019 Andrew C.R. Martin
---------------------------

Monitors an Instagram account each hour for the number of posts, 
followers and following. If no change, just prints a '.'.

Usage
-----


```
monitorig [-u=user] [-s=sleep] [-o=output]
       -u  Specify user account to monitor [andrewcrmartin]
       -s  Specify sleep time in hours [1]
       -o  Specify output file [$HOME/Dropbox/00NOTES/monitor.txt]
```


Typically you would run this with something like:

```
nohup ./monitorig.pl -u=username &> /tmp/monitorig.log &
```

