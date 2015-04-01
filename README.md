scripts-sysaudit
================

Goals:

-- Write portable UNIX based audit scripts. We assume you are running more that one flavor of UNIX.
-- Scripts will be setup to run against a list of hostnames or IP addresses, and assume you have key based access to those systems, to remotely execute commands, or push/pull data.

WARNING:  Although these scripts are written to "Do No Harm" and are passively collecting data, It is your responsiblity and duty as a Systems Admin to review and modify any code to run on your particular systems within your company guidelines. Use at your own risk, I assume no responsibility for damages or issues that may arise from the use of these scripts on your systems.  BE SMART, TEST IN DEVELOPMENT FIRST to see if you get the desired results.

This is a collection of scripts that I have written for the purposes of gathering system information.

These could be used for the purposes of collecting information on a new set of systems you would like to administer, or are becoming familiar with.

Some of these scripts were written for the purposes of collecting data in PCI and/or Sarbanes Oxley audits, or keeping data for those.  Now adays, many companies have implemented large syslog servers with data parsing searches, and SQL type reporting, HOWEVER, they never seem to be satisfied with the scope of systems included in their audit, and you maybe faced with the need to gather data quickly on a new system. These maybe of help.

Contributions:  If you wish to fork and contribute, by all means go ahead!  Please keep in mind that these scripts are trying to be platform agnostic, and may need hooks or functions written to specific OS requirments (i.e., RHEL vs. AIX vs. Solaris)
