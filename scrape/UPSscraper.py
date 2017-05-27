# -*- coding: utf-8 -*-
"""
Created on Tue May 23 14:08:43 2017
@author: jaturman
scrape UPS shipping times
Start up isntructions
1. download latest chrome driver at link below
https://sites.google.com/a/chromium.org/chromedriver/downloads
2. unzip and copy chromedriver.exe into directory below
'~\Python27
\Scripts'
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
from selenium.common.exceptions import NoSuchElementException

Origin = [14513,90815,94520,77017,75235,33304,63110,
         38116,15203,81003,98108,73179,30307,94128,92101]
Dest = pd.read_csv('destSample1.csv')
Dest = Dest['zip'].values.astype(str).tolist()
Trans = []

driver = webdriver.Chrome() 

for i in range(len(Origin)):
    for j in range(len(Dest)):
        # navigate to page
        driver.get("https://wwwapps.ups.com/ctc/%7B%7D")
        # begin navigating browser... straight forward
        elem = driver.find_element_by_name("origPostal")
        elem.send_keys(Origin[i])
        elem = driver.find_element_by_name("destPostal")
        elem.send_keys(Dest[j])
        # manually selected to monday july 17 2017
        # xpath must be manually changed to select a Monday
        # if ran after July 17 2017
        #elem = driver.find_element_by_xpath("//*[@id='ctcDatePicker']")
        #elem.send_keys('05/29/2017')
        #elem.send_keys(Keys.RETURN)
        elem = driver.find_element_by_name("ctc_submit")
        elem.send_keys(Keys.RETURN)
        # find result table by xpath 
        try:
            nd_early_air = elem.find_element_by_xpath("//*[@id='servicerow0']/td[2]/dl/dt/span/strong").get_attribute('innerHTML')
        except NoSuchElementException:
            nd_early_air = 0
            
        try:
            nd_air = elem.find_element_by_xpath("//*[@id='servicerow1']/td[2]/dl/dt/span/strong").get_attribute('innerHTML')
        except NoSuchElementException:
            nd_air = 0
            
        try:
            nd_air_saver = elem.find_element_by_xpath("//*[@id='servicerow2']/td[2]/dl/dt/span/strong").get_attribute('innerHTML')
        except NoSuchElementException:
            nd_air_saver = 0
        
        try:
            two_day_air_am = elem.find_element_by_xpath("//*[@id='servicerow3']/td[2]/dl/dt/span/strong").get_attribute('innerHTML')
        except NoSuchElementException:
            two_day_air_am = 0
            
        try:
            two_day_air = elem.find_element_by_xpath("//*[@id='servicerow4']/td[2]/dl/dt/span/strong").get_attribute('innerHTML')
        except NoSuchElementException:
            two_day_air = 0
        
        try:
            three_day_select = elem.find_element_by_xpath("//*[@id='servicerow5']/td[2]/dl/dt/span/strong").get_attribute('innerHTML')
        except NoSuchElementException:
            three_day_select = 0
        
        try:
            ground = elem.find_element_by_xpath("//*[@id='servicerow6']/td[2]/dl/dt/span/strong").get_attribute('innerHTML')
        except NoSuchElementException:
            ground = 0
        
        origin = Origin[i]
        destination = Dest[j]
        # assign to data frame 
        df = pd.DataFrame([[origin,destination,nd_early_air,nd_air,
                            nd_air_saver,two_day_air_am,two_day_air,
                            three_day_select,ground]],
                     columns=['origin','destination','nd_early_air',
                     'nd_air','nd_air_saver','two_day_air_am',
                     'two_day_air','three_day_select','ground'])
        Trans.append(df)
        

driver.close()      
pd.concat(Trans).to_csv('UPS.csv')
