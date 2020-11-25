#!/usr/bin/env python
# -*- coding: utf-8 -*-

import logging
import time
import os
import sys
import collections
import selenium.webdriver
import selenium.webdriver.support.ui as ui
import logging.handlers as handlers
from logging.handlers import RotatingFileHandler
from selenium import webdriver
from selenium.webdriver import ActionChains
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import Select
from selenium.common.exceptions import TimeoutException as SeleniumTimeoutException
from selenium.common.exceptions import NoSuchElementException
from selenium.common.exceptions import WebDriverException
from selenium.common.exceptions import StaleElementReferenceException
from selenium.webdriver.support.wait import WebDriverWait
from elements import *
from helpers import *

TIMEOUT = 10
SLOWPOKE_TIMEOUT = 320

def click_to_id_button(driver, click_object_id):
	logging.info("Started click element by ID")
	logging.info('driver: {0} click_object_id: {1}'.format(driver, click_object_id))
	try:
		button_find_and_click = driver_init_object.find_element_by_id(click_object_id).click()
		logging.info('button_find_and_click in first: {0}'.format(button_find_and_click))
	except:
		logging.info("NotImplementedExeption")
		pass
	logging.info('Completed block')

def configure_logger():
	scriptlogger = logging.getLogger('')
	scriptlogger.setLevel(logging.INFO)
	format = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
	to_stdout = logging.StreamHandler(sys.stdout)
	to_stdout.setFormatter(format)
	scriptlogger.addHandler(to_stdout)
	to_file = handlers.RotatingFileHandler(filename='/tmp/selenium-first-install.log', maxBytes=(1048576*5), backupCount=7)
	to_file.setFormatter(format)
	scriptlogger.addHandler(to_file)

def get_driver():
	logging.info('Logger Ok')
	global bitrix_ip
	bitrix_ip = "{{ bitrixip.stdout }}"
	global bitrix_url
	bitrix_url = "http://" + bitrix_ip
	b = selenium.webdriver.Chrome()
	wait = WebDriverWait(b, TIMEOUT)
	wait2 = WebDriverWait(b, SLOWPOKE_TIMEOUT)
	actor = Actions(wait)
	actor2 = Actions(wait2)
	logging.info('Prepare Get URL')
	b.get(bitrix_url)
	logging.info('Get Ok')
	driver = b
	return driver

def wizard_next_button(driver):
	frame = driver.find_element_by_class_name('wizard-next-button')
	return frame

def main():
	configure_logger()
	logging.info('Started')
	driver = get_driver()
	logging.info('driver: {0}'.format(driver))
	wait = WebDriverWait(driver, TIMEOUT)
	actor = Actions(wait)
	logging.info('............................................................................')
	logging.info('First click start')
	first_click = wizard_next_button(driver)
	if first_click is not None:
		first_click.click()
	logging.info('first_click: {0}'.format(first_click))
	logging.info('First click done')
	logging.info('............................................................................')
	logging.info('Click to license text start')
	actor2_license_text = Actions(wait)
	userlicense_text = actor2_license_text.wait_visible((By.NAME, "license_text"))
	logging.info('userlicense_text: {0}'.format(userlicense_text))
	userlicense_text.click()
	logging.info('userlicense_text: clicked')
	logging.info('............................................................................')
	logging.info('License agree click start')
	actor2_agree_license_click = Actions(wait)
	agree_license_click = actor2_agree_license_click.wait_element_located((By.ID, "agree_license_id"))
	logging.info('userlicense_text: {0}'.format(agree_license_click))
	agree_license_click.click()
	logging.info('License agree click done')
	logging.info('............................................................................')
	logging.info('Second click start')
	second_click = wizard_next_button(driver)
	if second_click is not None:
		second_click.click()
	logging.info('second_click: {0}'.format(second_click))
	logging.info('Second click done')
	logging.info('............................................................................')
	logging.info('UTF-8 set click start')
	actor2_utf_8_click = Actions(wait)
	utf_8_click = actor2_utf_8_click.wait_element_located((By.ID, "utf8_inst"))
	logging.info('userlicense_text: {0}'.format(utf_8_click))
	utf_8_click.click()
	logging.info('UTF-8 set click done')
	logging.info('............................................................................')
	logging.info('Set admin username start')
	actor2_set_adminname = Actions(wait)
	set_adminname = actor2_set_adminname.wait_element_located((By.ID, "user_name"))
	logging.info('set_adminname: {0}'.format(set_adminname))
	set_adminname.clear()
	set_adminname.send_keys("{{ bitrix_site_admin_user_name }}")
	logging.info('Set admin username done')
	logging.info('............................................................................')
	logging.info('Set admin surname start')
	actor2_set_adminsurname = Actions(wait)
	set_adminsurname = actor2_set_adminsurname.wait_element_located((By.ID, "user_surname"))
	logging.info('set_adminsurname: {0}'.format(set_adminsurname))
	set_adminsurname.clear()
	set_adminsurname.send_keys("{{ bitrix_site_admin_user_name }}")
	logging.info('Set admin surname done')
	logging.info('............................................................................')
	logging.info('Set admin email start')
	actor2_set_adminemail = Actions(wait)
	set_adminemail = actor2_set_adminemail.wait_element_located((By.ID, "email"))
	logging.info('set_adminemail: {0}'.format(set_adminemail))
	set_adminemail.clear()
	set_adminemail.send_keys("{{ bitrix_site_admin_email }}")
	logging.info('Set admin email done')
	logging.info('............................................................................')
	logging.info('anOther 1 click start')
	again_1_click = wizard_next_button(driver)
	if again_1_click is not None:
		again_1_click.click()
	logging.info('again_1_click: {0}'.format(again_1_click))
	logging.info('anOther 1 click done')
	logging.info('............................................................................')
	logging.info('Making sure currently place is needed start')
	NextStepID_data = driver.find_element_by_name("NextStepID")
	Currently_page = NextStepID_data.get_attribute('value')
	logging.info('Currently_page: {0}'.format(Currently_page))
	if Currently_page == "create_database":
		logging.info('CHECK RESULT: Currently page is create_database')
		Currently_page_click = wizard_next_button(driver)
		if Currently_page_click is not None:
			Currently_page_click.click()
			logging.info('Currently_page_click: {0}'.format(Currently_page_click))
	else:
		logging.info('CHECK RESULT: Currently page is not create_database')
	logging.info('Making sure currently place is needed done')
	logging.info('............................................................................')
	logging.info('Set __wiz_host start')
	actor2_set_wiz_host = Actions(wait)
	set_wiz_host = actor2_set_wiz_host.wait_element_located((By.NAME, "__wiz_host"))
	logging.info('set_wiz_host: {0}'.format(set_wiz_host))
	set_wiz_host.clear()
	set_wiz_host.send_keys("{{ mysqlip.stdout }}")
	logging.info('Set __wiz_host done')
	logging.info('............................................................................')
	logging.info('Set __wiz_user start')
	actor2_set_wiz_user = Actions(wait)
	set_wiz_user = actor2_set_wiz_user.wait_element_located((By.NAME, "__wiz_user"))
	logging.info('set_wiz_user: {0}'.format(set_wiz_user))
	set_wiz_user.clear()
	set_wiz_user.send_keys("{{ mysql_primary_user }}")
	logging.info('Set __wiz_user done')
	logging.info('............................................................................')
	logging.info('Set __wiz_password start')
	actor2_set_wiz_pass = Actions(wait)
	set_wiz_pass = actor2_set_wiz_pass.wait_element_located((By.NAME, "__wiz_password"))
	logging.info('set_wiz_pass: {0}'.format(set_wiz_pass))
	set_wiz_pass.clear()
	set_wiz_pass.send_keys("{{ mysql_root_password }}")
	logging.info('Set __wiz_password done')
	logging.info('............................................................................')
	logging.info('Set __wiz_database start')
	actor2_set_wiz_db = Actions(wait)
	set_wiz_db = actor2_set_wiz_db.wait_element_located((By.NAME, "__wiz_database"))
	logging.info('set_wiz_pass: {0}'.format(set_wiz_db))
	set_wiz_db.clear()
	set_wiz_db.send_keys("{{ mysql_root_database }}")
	logging.info('Set __wiz_database done')
	logging.info('............................................................................')
	logging.info('Select db type of index db start')
	select = Select(driver.find_element_by_css_selector('select'))
	select.select_by_visible_text('Innodb')
	logging.info('Select db type of index db done')
	logging.info('............................................................................')
	logging.info('anOther 2 click start')
	again_2_click = wizard_next_button(driver)
	if again_2_click is not None:
		again_2_click.click()
	logging.info('again_2_click: {0}'.format(again_2_click))
	logging.info('anOther 2 click done')
	logging.info('............................................................................')
	logging.info('Wait and set __wiz_admin_password start')
	wait2 = WebDriverWait(driver, SLOWPOKE_TIMEOUT)
	actor2_set_admin_password = Actions(wait2)
	wait_and_set_admin_password = actor2_set_admin_password.wait_element_located((By.NAME, "__wiz_admin_password"))
	logging.info('__wiz_admin_password: {0}'.format(wait_and_set_admin_password))
	wait_and_set_admin_password.clear()
	wait_and_set_admin_password.send_keys("{{ mysql_root_password }}")
	logging.info('Set __wiz_admin_password done')
	logging.info('............................................................................')
	logging.info('Wait and set __wiz_admin_password_confirm start')
	actor2_set_admin_password_confirm = Actions(wait)
	wait_and_set_admin_password_confirm = actor2_set_admin_password_confirm.wait_element_located((By.NAME, "__wiz_admin_password_confirm"))
	logging.info('__wiz_admin_password_confirm: {0}'.format(wait_and_set_admin_password_confirm))
	wait_and_set_admin_password_confirm.clear()
	wait_and_set_admin_password_confirm.send_keys("{{ mysql_root_password }}")
	logging.info('Set __wiz_admin_password_confirm done')
	logging.info('............................................................................')
	logging.info('anOther 3 click start')
	again_3_click = wizard_next_button(driver)
	if again_3_click is not None:
		again_3_click.click()
	logging.info('again_3_click: {0}'.format(again_3_click))
	logging.info('anOther 3 click done')
	logging.info('............................................................................')
	# logging.info('Select Bitrix Product type start')
	# actor2_set_bitrix_product = Actions(wait)
	# set_bitrix_product = actor2_set_bitrix_product.wait_element_located((By.ID, "id_radio_bitrix.sitecommunity:bitrix:demo_community"))
	# logging.info('set_bitrix_product: {0}'.format(set_bitrix_product))
	# set_bitrix_product.click()
	# logging.info('Select Bitrix Product type done')
	# logging.info('............................................................................')
	# logging.info('anOther 4 click start')
	# again_4_click = wizard_next_button(driver)
	# if again_4_click is not None:
	# 	again_4_click.click()
	# logging.info('again_4_click: {0}'.format(again_4_click))
	# logging.info('anOther 4 click done')
	# logging.info('............................................................................')
	# logging.info('Making sure currently place is needed start')
	# NextStepID_data_theme = driver.find_element_by_name("NextStepID")
	# Currently_page_theme = NextStepID_data_theme.get_attribute('value')
	# logging.info('Currently_page_theme: {0}'.format(Currently_page_theme))
	# if Currently_page_theme == "select_theme":
	# 	logging.info('CHECK RESULT: Currently page is select_theme')
	# 	Currently_page_click_theme = wizard_next_button(driver)
	# 	if Currently_page_click_theme is not None:
	# 		Currently_page_click_theme.click()
	# 		logging.info('Currently_page_click_theme: {0}'.format(Currently_page_click_theme))
	# else:
	# 	logging.info('CHECK RESULT: Currently page is not select_theme')
	# logging.info('Making sure currently place is needed done')
	# logging.info('............................................................................')
	# logging.info('Making sure currently place is needed start')
	# NextStepID_data_site_settings = driver.find_element_by_name("NextStepID")
	# Currently_page_site_settings = NextStepID_data_site_settings.get_attribute('value')
	# logging.info('Currently_page_theme: {0}'.format(Currently_page_site_settings))
	# if Currently_page_site_settings == "site_settings":
	# 	logging.info('CHECK RESULT: Currently page is site_settings')
	# 	Currently_page_click_site_settings = wizard_next_button(driver)
	# 	if Currently_page_click_site_settings is not None:
	# 		Currently_page_click_site_settings.click()
	# 		logging.info('Currently_page_click_site_settings: {0}'.format(Currently_page_click_site_settings))
	# else:
	# 	logging.info('CHECK RESULT: Currently page is not site_settings')
	# logging.info('Making sure currently place is needed done')
	# logging.info('............................................................................')
	# logging.info('Set site name start')
	# actor2_set_siteName = Actions(wait)
	# set_siteName = actor2_set_siteName.wait_element_located((By.ID, "siteName"))
	# logging.info('set_siteName: {0}'.format(set_siteName))
	# set_siteName.clear()
	# set_siteName.send_keys("{{ bitrix_site_name }}")
	# logging.info('Set site name done')
	# logging.info('............................................................................')
	# logging.info('Set site description start')
	# actor2_set_sitedesc = Actions(wait)
	# set_sitedesc = actor2_set_sitedesc.wait_element_located((By.ID, "siteDescription"))
	# logging.info('set_sitedesc: {0}'.format(set_sitedesc))
	# set_sitedesc.clear()
	# set_sitedesc.send_keys("{{ bitrix_site_description }}")
	# logging.info('Set site description done')
	# logging.info('............................................................................')
	# logging.info('Set site meta description start')
	# actor2_set_sitemetadesc = Actions(wait)
	# set_sitemetadesc = actor2_set_sitemetadesc.wait_element_located((By.ID, "siteMetaDescription"))
	# logging.info('set_sitemetadesc: {0}'.format(set_sitemetadesc))
	# set_sitemetadesc.clear()
	# set_sitemetadesc.send_keys("{{ bitrix_site_meta_description }}")
	# logging.info('Set site meta description done')
	# logging.info('............................................................................')
	# logging.info('Set site meta keywords start')
	# actor2_set_sitemetakeys = Actions(wait)
	# set_sitemetakeys = actor2_set_sitemetakeys.wait_element_located((By.ID, "siteMetaKeywords"))
	# logging.info('set_sitemetadesc: {0}'.format(set_sitemetakeys))
	# set_sitemetakeys.clear()
	# set_sitemetakeys.send_keys("{{ bitrix_site_keywords }}")
	# logging.info('Set site meta keywords done')
	# logging.info('............................................................................')
	# logging.info('anOther 5 click start')
	# again_5_click = wizard_next_button(driver)
	# if again_5_click is not None:
	# 	again_5_click.click()
	# logging.info('again_5_click: {0}'.format(again_5_click))
	# logging.info('anOther 5 click done')
	# logging.info('............................................................................')
	# actor2_set_waiting_action_page = Actions(wait2)
	# wait_action_page = actor2_set_waiting_action_page.wait_element_located((By.NAME, "StepNext"))
	# logging.info('wait_action_page: {0}'.format(wait_action_page))
	# logging.info('............................................................................')
	# logging.info('Making sure currently place is needed start')
	# NextStepID_finish = driver.find_element_by_name("NextStepID")
	# Currently_page_finish = NextStepID_finish.get_attribute('value')
	# logging.info('Currently_page_finish: {0}'.format(Currently_page_finish))
	# if Currently_page_finish == "finish":
	# 	logging.info('CHECK RESULT: Currently page is finish')
	# 	Currently_page_click_finish = wizard_next_button(driver)
	# 	if Currently_page_click_finish is not None:
	# 		Currently_page_click_finish.click()
	# 		logging.info('Currently_page_click_finish: {0}'.format(Currently_page_click_finish))
	# else:
	# 	logging.info('CHECK RESULT: Currently page is not finish')
	# logging.info('Making sure currently place is needed done')
	logging.info('............................................................................')
	logging.info('Finished')
	driver.quit()
	sys.exit(0)

if __name__ == "__main__":
	# execute only if run as a script
	main()