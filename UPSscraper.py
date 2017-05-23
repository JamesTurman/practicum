# -*- coding: utf-8 -*-
"""
Created on Tue May 23 14:08:43 2017

@author: jaturman

scrape UPS shipping times

Start up isntructions
1. download latest chrome driver at link below
https://sites.google.com/a/chromium.org/chromedriver/downloads
2. unzip and copy chromedriver.exe into directory below
'~\Python27\Scripts'
3. navigate to Python directory on command line then run commands below
pip install pandas
pip install selenium
pip install bs4
pip install html5lib
You're good to run the script after all 3 steps are completed
"""

import os
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
import pandas as pd
from bs4 import BeautifulSoup
import html5lib as hlib

driver = webdriver.Chrome() 
""" 15 origin zip codes from research
Origin = [14513,90815,94520,77017,75235,33304,63110,
         38116,15203,81003,98108,73179,30307,94128,92101]
"""
# sample origin and destination for testing
Origin = [14513,90815]
Dest = [63110,38116]
Trans = []

for i in range(len(Origin)):
    for j in range(len(Dest)):
        # navigate to page
        driver.get("https://wwwapps.ups.com/ctc/%7B%7D")
        # begin navigating browser... straight forward
        elem = driver.find_element_by_name("origPostal")
        elem.send_keys(Origin[i])
        elem = driver.find_element_by_name("destPostal")
        elem.send_keys(Dest[j])
        elem = driver.find_element_by_name("pickerDate")
        # assign date to a monday
        # format == mm/dd/yyyy
        elem.send_keys("05/29/2017") 
        elem = driver.find_element_by_name("ctc_submit")
        elem.click()
        # find result table by xpath 
        tbl = driver.find_element_by_xpath("//*[@id='results']/div[1]/div[2]/div/table").get_attribute('outerHTML')
        df  = pd.read_html(tbl)
        Trans.append(df)
        Trans = pd.concat(Trans,axis=1)
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        