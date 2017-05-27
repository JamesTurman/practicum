# -*- coding: utf-8 -*-
"""
Created on Fri May 26 10:01:11 2017

@author: jaturman

formatting data from FedEx for zip to zone file
data must only show the number of days in transit not 
the estimated arrival date

any 0 in the offering columns means the service is not offered
for that combination of shipping zipcodes
"""

import pandas as pd
import numpy as np
from datetime import datetime

# read in data
dat = pd.read_csv("FedEx.csv")

########## split ship_info on ; #################
# 0 values get nan
dat['ship_info'] = dat.ship_info.str.split(';').str[1]
# remove period at the end of each string
dat['ship_info'] = dat.ship_info.str.split('.').str[0]
# confirm split is correct
dat['ship_info'].head(1)

########## split first overnight ###########
dat['first_overnight'] = dat.first_overnight.str.split('by').str[0]
dat['first_overnight'] = dat['first_overnight'].map(lambda x: str(x)[4:-1])

########## split priority overnight ###########
dat['priority_overnight'] = dat.priority_overnight.str.split('by').str[0]
dat['priority_overnight'] = dat['priority_overnight'].map(lambda x: str(x)[4:-1])

########## split standard overnight ###########
dat['standard_overnight'] = dat.standard_overnight.str.split('by').str[0]
dat['standard_overnight'] = dat['standard_overnight'].map(lambda x: str(x)[4:-1])

########## split twoday_AM ###########
dat['twoday_AM'] = dat.twoday_AM.str.split('by').str[0]
dat['twoday_AM'] = dat['twoday_AM'].map(lambda x: str(x)[4:-1])

########## split twoday ###########
dat['twoday'] = dat.twoday.str.split('by').str[0]
dat['twoday'] = dat['twoday'].map(lambda x: str(x)[4:-1])

########## split express_saver ###########
dat['express_saver'] = dat.express_saver.str.split('by').str[0]
dat['express_saver'] = dat['express_saver'].map(lambda x: str(x)[4:-1])

######### split ground #################
dat['ground'] = dat.ground.str.split('(').str[1]
dat['ground'] = dat['ground'].map(lambda x: str(x)[0])
dat['ground'] = dat['ground'].map(lambda x: 0 if x == 'n' else x)

# dates have been formatted 
dates = dat
"""
### for testing
dates['ship_info'] = pd.to_datetime(dates['ship_info'],errors='coerce')
"""
# function to format
def dateform(df,colname):
    df[colname] = pd.to_datetime(df[colname],errors='coerce')
    
dateform(dates,'ship_info')
dateform(dates,'first_overnight')
dateform(dates,'priority_overnight')
dateform(dates,'standard_overnight')
dateform(dates,'twoday_AM')
dateform(dates,'twoday')
dateform(dates,'express_saver')

# get the difference between each column date and the ship_info date
def datediff(df,start,end):
    df[end] = df[end]-df[start]

datediff(dates,'ship_info','first_overnight')
datediff(dates,'ship_info','priority_overnight')
datediff(dates,'ship_info','standard_overnight')
datediff(dates,'ship_info','twoday_AM')
datediff(dates,'ship_info','twoday')
datediff(dates,'ship_info','express_saver')

def days(df,col):
    df[col] = df[col].map(lambda x: str(x)[0])
    df[col] = df[col].map(lambda x: 0 if x == 'N' else x)
    
days(dates,'first_overnight')
days(dates,'priority_overnight')
days(dates,'standard_overnight')
days(dates,'twoday_AM')
days(dates,'twoday')
days(dates,'express_saver')

# write results to CSV
dates.to_csv('cleanFedEx.csv')
