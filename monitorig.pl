#!/usr/bin/perl -s
#*************************************************************************
#
#   Program:    monitorig
#   File:       monitorig.pl
#   
#   Version:    V1.3
#   Date:       27.10.20
#   Function:   Monitor an Instagram account
#   
#   Copyright:  (c) Andrew C. R. Martin, 2019-20
#   Author:     Andrew C. R. Martin
#   EMail:      andrew@andrew-martin.org
#               
#*************************************************************************
#
#   This program is not in the public domain, but it may be copied
#   according to the conditions laid out in the accompanying file
#   COPYING.DOC
#
#   The code may be modified as required, but any modifications must be
#   documented so that the person responsible can be identified. If 
#   someone else breaks this code, I don't want to be blamed for code 
#   that does not work! 
#
#   The code may not be sold commercially or included as part of a 
#   commercial product except as described in the file COPYING.DOC.
#
#*************************************************************************
#
#   Description:
#   ============
#
#*************************************************************************
#
#   Usage:
#   ======
#   nohup ./monitorig.pl [-u=username] [-o=outputfile] [-s=sleepTime] &
#
#*************************************************************************
#
#   Revision History:
#   =================
#   V1.0    11.07.19  Original   By: ACRM
#   V1.1    19.07.19  Now monitors every hour, but just outputs a '.'
#                     unless the data have changed.
#   V1.2    15.11.19  Fixed some '' strings to ""
#   V1.3    27.10.20  Prints single character error codes instead of
#                     full messages
#
#*************************************************************************
# Add the path of the executable to the library path
use FindBin;
use lib $FindBin::Bin;
# Or if we have a bin directory and a lib directory
#use Cwd qw(abs_path);
#use FindBin;
#use lib abs_path("$FindBin::Bin/../lib");

use strict;

# Set defaults
my $defaultUser   = "andrewcrmartin";
my $defaultOutput = "$ENV{'HOME'}/Dropbox/00NOTES/monitor.txt";
my $defaultSleep  = 1; # hours

UsageDie($defaultUser, $defaultOutput, $defaultSleep) if(defined($::h));

# Read from command line
my $user      = defined($::u)?$::u:$defaultUser;
my $ofile     = defined($::o)?$::o:$defaultOutput;
my $sleepTime = defined($::s)?$::s:$defaultSleep;

my $tfile     = "/var/tmp/monitorig_$$";
my $url       = "https://www.instagram.com/$user/";
my $sleepTime = $sleepTime*60*60;
my $LastData  = '';
my $CRStatus  = 1;

while(1)
{
    GrabFile($tfile, $url);
    my($error, $followers, $following, $posts) = GrabData($tfile);
    unlink($tfile);

    if($error == 0)
    {
        if(DataChanged(\$LastData, $posts, $followers, $following))
        {
            WriteMessage($ofile, \$CRStatus, '', $posts, $followers, $following);
        }
        else
        {
            WriteMessage($ofile, \$CRStatus, '.', 0, 0, 0);
        }
    }
    elsif($error == 1)
    {
        WriteMessage($ofile, \$CRStatus, "Z", 0, 0, 0);
    }
    elsif($error == 2)
    {
        WriteMessage($ofile, \$CRStatus, "X", 0, 0, 0);
    }
    else
    {
        WriteMessage($ofile, \$CRStatus, "U", 0, 0, 0);
    }
    sleep($sleepTime);
}

#*************************************************************************
sub GrabFile
{
    my($file, $url) = @_;
    `wget -q -O $file $url`;
}

#*************************************************************************
sub GrabData
{
    my($file) = @_;

    my $followers = 0;
    my $following = 0;
    my $posts     = 0;
    my $found     = 0;
    
    if(open(my $in, '<', $file))
    {
        while(<$in>)
        {
            if(/\<meta .*?content="([\d,]+) Followers.*?([\d,]+) Following.*?([\d,]+) Posts/)
            {
                $followers = $1;
                $following = $2;
                $posts     = $3;
                $found     = 1;
                last;
            }
        }
        close($in);
        
        if(!$found)
        {
            # File format changed
            return(2, 0, 0, 0);
        }
    }
    else
    {
        # File not grabbed
        return(1, 0, 0, 0);
    }

    return(0, $followers, $following, $posts);
}

#*************************************************************************
sub WriteMessage
{
    my($ofile, $pCRStatus, $msg, $posts, $followers, $following) = @_;

    $posts     =~ s/\,//g;
    $followers =~ s/\,//g;
    $following =~ s/\,//g;
    
    if(open(my $fp, '>>', $ofile))
    {
        if($msg eq '.')
        {
            printf($fp '.');
            $$pCRStatus = 0;
        }
        elsif($msg ne '')
        {
            printf($fp "\n") if($$pCRStatus == 0);
            printf($fp "%s : ERROR! $msg", GetDateTime());
            $$pCRStatus = 1;
        }
        else
        {
            printf($fp "\n") if($$pCRStatus == 0);
            printf($fp "%s : $posts/$followers/$following\n", GetDateTime());
            $$pCRStatus = 1;
        }
        
        close($fp);
    }
    else
    {
        print(STDERR "ERROR! Unable to write log file $ofile\n");
        exit 1;
    }
}

#*************************************************************************
sub GetDateTime
{
    my @parts = localtime(time);
    my $mday  = $parts[3];
    my $mon   = $parts[4]+1;
    my $year  = $parts[5] + 1900;
    my $hour  = $parts[2];
    my $mins  = $parts[1];
    my $dateTime = sprintf("$mday/$mon/$year $hour:%2d", $mins);
    return($dateTime);
}

#*************************************************************************
sub IsTime
{
    my($expectedHour) = @_;

    my @parts = localtime(time);
    my $hour  = $parts[2];

    if($hour == $expectedHour)
    {
        return(1);
    }

    return(0);
}


#*************************************************************************
sub DataChanged
{
    my($pLastData, $posts, $followers, $following) = @_;

    my $newData = "$posts:$followers:$following";
    if($newData ne $$pLastData)
    {
        $$pLastData = $newData;
        return(1);
    }

    return(0);
}


#*************************************************************************
sub UsageDie
{
    my($defaultUser, $defaultOutput, $defaultSleep) = @_;

    print <<__EOF;

monitorig V1.3 (c) 2019-20 Andrew C.R. Martin

Usage: monitorig [-u=user] [-s=sleep] [-o=output]
       -u  Specify user account to monitor [$defaultUser]
       -s  Specify sleep time in hours [$defaultSleep]
       -o  Specify output file [$defaultOutput]

Monitors an Instagram account each hour for the number of posts, 
followers and following. If no change, just prints a '.'.

If an error occurs, instead of a '.', it will print
X - unable to parse the downloaded page
Z - unable to download the instagram page
U - undefined error

__EOF
    exit 0;
}
