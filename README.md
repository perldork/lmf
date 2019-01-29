# LMF - A log monitoring framework

HAHAHAHAA HOOOOO HOOOO

LMF lets you monitor many log files with multiple patterns each at
once.  Configurations for these log file matchers are kept in 
configuration 'snippets' located in the config/ directory under the
LMF home directory or on a web server that can be accessed over HTTP
or HTTPS, with or without apache authentication.

For example, for a local configuration, you might have:

config/
   apache.conf
   dns.conf
   ssh.conf

You can name your snippets however you like, just remember to use
'.conf' as the suffix for the name.

This version of LMF also supports loading its' configuration from a
remote HTTP/HTTPS source with or without HTTP AUTH protection.  This
allows you to have a number of LMF clients all using configuration
files stored and managed on a central server.  If each client is
restarted every night or every N hours via cron it would pick up
any new configurations or changed configurations on the remote server.

For more documentation and an example of how to do this, read the
README file and configuration example files in

misc/http-config.dist/

## Global options

Global options are found in config/main.conf, they are as follows:

```
[main]
#  Syslog level to use
syslog-level = LOCAL3
#  How often, in seconds, should each pattern be checked for in
#  the log files?  Set to a higher number to reduce the load LMF
#  puts on the system (5 should be fine for most systems), set
#  to a lower number to have it check more often.  Most people
#  will not need to change this.
interval = 5
#  Set to 1 to see verbose debugging information
debug = 0

[main-action-queue]
#  File that holds triggered actions, when they were started, and
#  program to run apon release.   lmf-released reads this file,
#  lmf-monitord appends to this file.
db = /usr/local/lmf/data/queue.db

#  Field separator for action-queue log file
field-separator = ^T^K^O
```

## Configuring a log file matcher

Each configuration has a 'name' section that is formatted like so:

[This is the name of my rule]

It also uses a number of fields, listed under the name section,
each separated by a new line.  A complete configuration is shown
below for a matcher that detects ssh brute force attempts, lines
with # describe each field.

```
[SSH brute force attempt]
#  What file this matcher looks at
file = /var/log/secure
#  The pattern we are looking for in the file, using perl
#  regular expressions
pattern = Illegal user \S+ from (\S+)
#  How many times does this pattern have to match before
#  we take an action?
threshold = 6
#  What time frame are we looking at for number of hits on
#  this rule to trigger an action.  In this case, 6 matches
#  within 2 minutes would trigger an action.  Use 'm' for
#  minutes, 's' for seconds, or 'h' for hours when designating
#  times.  If you use no designtation, seconds is assumed :).
within = 2m
#  How long AFTER a triggered action should we run the release
#  action?  Use 0 for 'never'
duration = 3h
#  Script to run when 'threshold' matches are found within 
#  'within' period of time.  Use %N variables to substitute
#  in data you requested from the pattern.  In the pattern above,
#  %1 will match the IP address of the user '\S+ from (\S+)' .. the
#  parenthesis 'capture' that data from the matched entries .. just
#  as in perl.
trigger = /usr/local/lmf/actions/fw drop %1
#  Script to run to 'undo' whatever action was done when the match
#  was triggered.
release = /usr/local/lmf/actions/fw allow %1
#  Message to put in syslog when this action is triggered 
message = Brute force SSH scan from %1 (%count attempts in %time seconds)
```

The folling additional 'meta' variables can be used in the configuration
directives 'message', 'trigger', and 'release':
* %count - number of matches that triggered this action
* %threshold - number of matches that triggers this action
* %duration - number of seconds before release is executed
             (0 if no release is set up)
* %within - number of seconds threshold number of matches have
               to be found in for us to consider this a match
* %name - Name of the rule that is matched
* %file - File the match was found in
* %time - Number of seconds it took for this match to be triggered
* %pct - % of the time threshold (within) it took for this match
         to be triggered

Additionally, the 'trigger' and 'release' directives can use %message
to use the fully formatted message for this match (same as the message
lmf-monitord sends to syslog).

## Installing LMF

!! Important: wherever you untarred/unzipped LMF *is* its home directory !!

* cd to the LMF home directory
* Set up your configuration snippets.  Examples are in config/dist/, feel free to use those or set up your own.  We will provide a configuration snippet repository at some point in the near future to help you with this process.
3) Run the install script ```bash ./install.sh```

Note: the installer will install perl modules using the CPAN module of
perl, if you have not used CPAN before you will be asked a series of
questions by the *CPAN* installer as it sets up CPAN for you.  If you
are not familiar with this process, you can learn about it from
www.perl.com or via google.com, or we will be glad to set this script
up for you for a 30 minute charge.

## Start LMF!

```
/sbin/service lmf restart
```

Log file for lmf will be /var/log/lmf.log

Email any questions you have about this script at

maxs@webwizarddesign.com

Make sure to include the string "[LMF question]" in the subject.
