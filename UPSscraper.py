# -*- coding: utf-8 -*-
"""
Created on Tue May 23 14:08:43 2017
@author: jaturman
scrape UPS shipping times
Start up isntructions
1. download latest chrome driver at link below
https://sites.google.com/a/chromium.org/chromedriver/downloads
2. unzip and copy chromedriver.exe into directory below
'~\Python\Scripts'
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
        # manually selected to monday july 17 2017
        # xpath must be manually changed to select a Monday
        # if ran after July 17 2017
        #elem = driver.find_element_by_xpath("//*[@id='ctcDatePicker']")
        #elem.send_keys('05/29/2017')
        #elem.send_keys(Keys.RETURN)
        elem = driver.find_element_by_name("ctc_submit")
        elem.send_keys(Keys.RETURN)
        # find result table by xpath 
        nd_early_air = elem.find_element_by_xpath("//*[@id='servicerow0']/td[2]/dl/dt/span/strong").get_attribute('innerHTML')
        nd_air = elem.find_element_by_xpath("//*[@id='servicerow1']/td[2]/dl/dt/span/strong").get_attribute('innerHTML')
        nd_air_saver = elem.find_element_by_xpath("//*[@id='servicerow2']/td[2]/dl/dt/span/strong").get_attribute('innerHTML')
        two_day_air_am = elem.find_element_by_xpath("//*[@id='servicerow3']/td[2]/dl/dt/span/strong").get_attribute('innerHTML')
        two_day_air = elem.find_element_by_xpath("//*[@id='servicerow4']/td[2]/dl/dt/span/strong").get_attribute('innerHTML')
        three_day_select = elem.find_element_by_xpath("//*[@id='servicerow5']/td[2]/dl/dt/span/strong").get_attribute('innerHTML')
        ground = elem.find_element_by_xpath("//*[@id='servicerow6']/td[2]/dl/dt/span/strong").get_attribute('innerHTML')
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