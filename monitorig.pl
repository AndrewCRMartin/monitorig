#!/usr/bin/perl -s
#*************************************************************************
#
#   Program:    monitorig
#   File:       monitorig.pl
#   
#   Version:    V1.0
#   Date:       11.07.19
#   Function:   Monitor an Instagram account
#   
#   Copyright:  (c) Andrew C. R. Martin, 2010
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

while(1)
{
    if(IsTime(12) || IsTime(17) || IsTime(23))
    {
        GrabFile($tfile, $url);
        my($error, $followers, $following, $posts) = GrabData($tfile);
        unlink($tfile);

        if($error == 0)
        {
            WriteMessage($ofile, '', $posts, $followers, $following);
        }
        elsif($error == 1)
        {
            WriteMessage($ofile, 'Failed to download Instagram page!', 0, 0, 0);
        }
        elsif($error == 2)
        {
            WriteMessage($ofile, 'Instagram page format has changed!!!', 0, 0, 0);
        }
        else
        {
            WriteMessage($ofile, 'Undefined error!', 0, 0, 0);
        }
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
    my($ofile, $msg, $posts, $followers, $following) = @_;

    $posts     =~ s/\,//g;
    $followers =~ s/\,//g;
    $following =~ s/\,//g;
    
    if(open(my $fp, '>>', $ofile))
    {
        if($msg ne '')
        {
            printf($fp "%s : ERROR! $msg\n", GetDateTime());
        }
        else
        {
            printf($fp "%s : $posts/$followers/$following\n", GetDateTime());
        }
        
        close($fp);
    }
    else
    {
        print("ERROR! Unable to write log file $ofile\n");
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
sub UsageDie
{
    my($defaultUser, $defaultOutput, $defaultSleep) = @_;

    print <<__EOF;

monitorig V1.0 (c) 2019 Andrew C.R. Martin

Usage: monitorig [-u=user] [-s=sleep] [-o=output]
       -u  Specify user account to monitor [$defaultUser]
       -s  Specify sleep time in hours [$defaultSleep]
       -o  Specify output file [$defaultOutput]

Monitors an Instagram account checking at 12pm, 5pm and 11pm for number
of posts, followers and following.

__EOF
    exit 0;
}
