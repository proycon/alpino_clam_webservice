#!/usr/bin/env python
#-*- coding:utf-8 -*-

###############################################################
# CLAM: Computational Linguistics Application Mediator
# -- CLAM Wrapper script Template --
#       by Maarten van Gompel (proycon)
#       http://ilk.uvt.nl/~mvgompel
#       Induction for Linguistic Knowledge Research Group
#       Universiteit van Tilburg
#
#       Licensed under GPLv3
#
###############################################################

#This is a test wrapper, meant to illustrate how easy it is to set
#up a wrapper script for your system using Python and the CLAM Client API.
#We make use of the XML configuration file that CLAM outputs, rather than
#passing all parameters on the command line.

#This script will be called by CLAM and will run with the current working directory set to the specified project directory

#import some general python modules:
import sys
import os
import codecs
import re
import string
import glob

#import CLAM-specific modules. The CLAM API makes a lot of stuff easily accessible.
import clam.common.data
import clam.common.status

from alpino import CUSTOM_FORMATS

#make a shortcut to the shellsafe() function
shellsafe = clam.common.data.shellsafe

#this script takes three arguments from CLAM: $DATAFILE $STATUSFILE $OUTPUTDIRECTORY  (as configured at COMMAND= in the service configuration file)
datafile = sys.argv[1]
statusfile = sys.argv[2]
outputdir = sys.argv[3]
ALPINO_HOME = sys.argv[4]


#Obtain all data from the CLAM system (passed in $DATAFILE (clam.xml))
clamdata = clam.common.data.getclamdata(datafile, CUSTOM_FORMATS)

#You now have access to all data. A few properties at your disposition now are:
# clamdata.system_id , clamdata.project, clamdata.user, clamdata.status , clamdata.parameters, clamdata.inputformats, clamdata.outputformats , clamdata.input , clamdata.output

clam.common.status.write(statusfile, "Starting...")

#SOME EXAMPLES (uncomment and adapt what you need)

#-- Iterate over all input files? --

for inputfile in clamdata.input:
    if not os.path.exists("xml"):
        os.mkdir("xml")
    else:
        for filename in glob.glob('xml/*.xml'):
            os.unlink(filename) #clear for next round

    inputtemplate = inputfile.metadata.inputtemplate
    inputfilepath = str(inputfile)
    basename = os.path.basename(inputfile)[:-4] #without extension
    tokfile = basename + '.tok'
    if inputtemplate == 'untokinput':
        #we have to tokenize first
        clam.common.status.write(statusfile, "Tokenizing " + basename)
        r = os.system('ucto -L nl -n ' + shellsafe(inputfilepath,'"') + ' > ' + shellsafe(os.path.join(outputdir,tokfile),'"'))
        if r != 0:
            print("Failure running ucto",file=sys.stderr)
            sys.exit(2)

    clam.common.status.write(statusfile, "Running Alpino on " + basename)
    pwd = os.getcwd()
    os.chdir(outputdir)
    r = os.system("ALPINO_HOME=" + shellsafe(ALPINO_HOME) + " " + ALPINO_HOME + "/bin/Alpino -veryfast -flag treebank xml debug=1 end_hook=xml user_max=900000 -parse < "  + tokfile)
    if r != 0:
        print("Failure running alpino",file=sys.stderr)
        sys.exit(2)

    os.chdir("xml")
    os.system("zip ../" + basename + ".alpinoxml.zip *.xml")
    os.chdir(pwd)


#A nice status message to indicate we're done
clam.common.status.write(statusfile, "Done",100) # status update

sys.exit(0) #non-zero exit codes indicate an error and will be picked up by CLAM as such!
