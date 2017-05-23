# -*- coding: utf-8 -*-
"""
Spyder Editor
This is a script to scrape shipping data from FedEx website via seleium server
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
packageNum = 1
packageWeight = 1
trans = []
for i in range(len(Origin)):
    for j in range(len(Dest)):
        # navigate to the application home page
        driver.get("https://www.fedex.com/ratefinder/home?cc=US&language=en&locId=express")
        elem = driver.find_element_by_name("origZip")
        elem.send_keys(Origin[i])
        elem = driver.find_element_by_name("destZip")
        elem.send_keys(Dest[j])
        # most likely dont need this... auto populates at 1
        #elem = driver.find_element_by_name("totalNumberOfPackages")
        #elem.send_keys(1)
        elem = driver.find_element_by_id("totalPackageWeight")
        elem.send_keys(1) # 1 lbs package
        elem = driver.find_element_by_xpath("//*[@id='raCodeId']/option[3]")
        elem.click() # set option for pick up
        elem = driver.find_element_by_id("quickQuote")
        elem.click() # click to advance 
        # read results after moving to quote page
        tbl = driver.find_element_by_xpath("//*[@id='content']/div/div/form/table[2]/tbody/tr/td/table[2]/tbody/tr/td[1]/table/tbody/tr[1]/td[2]/table").get_attribute('outerHTML')
        df  = pd.read_html(tbl)
        trans.append(df)
        trans = pd.concat(trans,axis=1)
        
        
        
        
        