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
from selenium.common.exceptions import NoSuchElementException

# 15 origin zip codes from research
Orgin = [14513,90815,94520,77017,75235,33304,63110,
         38116,15203,81003,98108,73179,30307,94128,92101]
Dest = pd.read_csv('destSample1.csv')
Dest = Dest['zip'].values.astype(str).tolist()

trans = []

driver = webdriver.Chrome()

#from selenium.common.exceptions import NoSuchElementException        
#def check_exists_by_xpath(xpath):
 #   try:
  #      webdriver.find_element_by_xpath(xpath)
   # except NoSuchElementException:
    #    return False
    #return True

for i in range(len(Orgin)):
    for j in range(len(Dest)):
        # navigate to the application home page
        driver.get("https://www.fedex.com/ratefinder/home?cc=US&language=en&locId=express")
        elem = driver.find_element_by_name("origZip")
        elem.send_keys(Orgin[i])
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
        try:
            ship_info = driver.find_element_by_xpath("//*[@id='content']/div/div/form/table[2]/tbody/tr/td/table[1]/tbody/tr[4]/td[2]/table/tbody/tr[1]/td/table/tbody/tr[4]/td[2]/b").get_attribute('innerHTML')
        except NoSuchElementException:
            ship_info = 0
            
        try:
            first_overNight = driver.find_element_by_xpath("//*[@id='FIRST_OVERNIGHT_dateTime0']").get_attribute('innerHTML')
        except NoSuchElementException:
            first_overNight = 0
            
        try:
            priority_overNight = driver.find_element_by_xpath("//*[@id='PRIORITY_OVERNIGHT_dateTime1']").get_attribute('innerHTML')
        except NoSuchElementException:
            priority_overNight = 0
        
        try:
            standard_overNight = driver.find_element_by_xpath("//*[@id='STANDARD_OVERNIGHT_dateTime2']").get_attribute('innerHTML')
        except NoSuchElementException:
            standard_overnight = 0
        
        try:
            twoday_AM = driver.find_element_by_xpath("//*[@id='FEDEX_2_DAY_AM_dateTime3']").get_attribute('innerHTML')
        except NoSuchElementException:
            twoday_AM = 0
            
        try:    
            twoday = driver.find_element_by_xpath("//*[@id='FEDEX_2_DAY_dateTime4']").get_attribute('innerHTML')
        except NoSuchElementException:    
            twoday = 0
            
        try:    
            express_saver = driver.find_element_by_xpath("//*[@id='FEDEX_EXPRESS_SAVER_dateTime5']").get_attribute('innerHTML')
        except NoSuchElementException:
            express_saver = 0
        
        try:
            ground = driver.find_element_by_xpath("//*[@id='FEDEX_GROUND_dateTime6']").get_attribute('innerHTML')
        except NoSuchElementException:
            ground = 0
            
        
        origin = Orgin[i]
        destination = Dest[j]
        # append to data frame "trans"
        df = pd.DataFrame([[origin,destination,ship_info,first_overNight,
                               priority_overNight,standard_overNight,twoday_AM,
                               twoday,express_saver,ground]],
                     columns=['origin','destination','ship_info',
                     'first_overnight','priority_overnight','standard_overnight',
                     'twoday_AM','twoday','express_saver','ground'])
        trans.append(df)
        

driver.close()   
pd.concat(trans).to_csv('FedEx.csv')
