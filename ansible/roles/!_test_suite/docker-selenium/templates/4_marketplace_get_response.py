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
SLOWPOKE_TIMEOUT = 100

def configure_logger():
	scriptlogger = logging.getLogger('')
	scriptlogger.setLevel(logging.INFO)
	format = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
	to_stdout = logging.StreamHandler(sys.stdout)
	to_stdout.setFormatter(format)
	scriptlogger.addHandler(to_stdout)
	to_file = handlers.RotatingFileHandler(filename='/tmp/selenium-marketplace-install.log', maxBytes=(1048576*5), backupCount=7)
	to_file.setFormatter(format)
	scriptlogger.addHandler(to_file)

def wait_element_by_xpath(driver, element):
	logging.info('driver: {0} element: {1}'.format(driver, element))
	try:
		wait = WebDriverWait(driver, 10)
		my_current_element = wait.until(EC.presence_of_element_located((By.XPATH, element)))
		logging.info('my_current_element: {0}'.format(my_current_element))
	except:
		time.sleep(2)
		logging.info('Not found element: {0}'.format(element))
		pass
	logging.info('element: {0}'.format(element))

# MAIN SETTINGS

def click_xpath_module_contain_main(driver, modulename):
	logging.info('driver: {0} modulename: {1}'.format(driver, modulename))
	request_path_main_element = (".//*[contains(@id, '{0}')]").format(modulename)
	logging.info('request_path_main_element: {0}'.format(request_path_main_element))
	request_path_second_element = ("//*[substring-after(name(), 'TEMPLATE') = '']")
	next_button = '//option[@value="main"]'
	logging.info('request_path_second_element: {0}'.format(request_path_second_element))
	request_to_xpath = '{0}{1}{2}'.format(request_path_main_element, request_path_second_element, next_button)
	logging.info('request_to_xpath: {0}'.format(request_to_xpath))	
	wait_element_by_xpath(driver, request_to_xpath)
	finded_element = driver.find_element(By.XPATH, request_to_xpath).click()
	logging.info('We perform delete finded_element: {0}'.format(finded_element))
	finded_element_next_button = driver.find_element(By.XPATH, request_to_xpath).click()

def login_to_admin():
	logging.info('Logger Ok')
	global bitrix_ip
	#bitrix_ip = "production.toprussianbloggers.ru"
	bitrix_ip = "{{ bitrixip.stdout }}"
	#bitrix_url = "http://" + bitrix_ip
	global bitrix_url
	bitrix_url = "http://" + bitrix_ip
	global bitrix_url_admin
	bitrix_url_admin = bitrix_url + "/bitrix/admin/module_admin.php?lang=en"
	b = selenium.webdriver.Chrome()
	wait = WebDriverWait(b, TIMEOUT)
	wait2 = WebDriverWait(b, SLOWPOKE_TIMEOUT)
	actor = Actions(wait)
	actor2 = Actions(wait2)
	logging.info('Prepare Get URL')
	#b.get('http://{{ bitrixip.stdout }}/bitrix/admin/module_admin.php?lang=en')
	b.get(bitrix_url_admin)
	logging.info('Get Ok')
	global template_url
	global site_edit_url
	template_url_ip = "http://" + bitrix_ip
	template_url = template_url_ip + "/bitrix/admin/template_edit.php?lang=en&ID=main"
	site_edit_url = template_url_ip + "/bitrix/admin/partner_modules.php?lang=en"
	logging.info('template_url: {0}'.format(template_url))
	password_status = actor.wait_visible_pass(USER_PASSWORD)
	logging.info('Password status {0}'.format(password_status))
	actor.wait_clickable(USER_LOGIN).send_keys('admin')
	actor.wait_visible(USER_PASSWORD).click()
	#actor.wait_clickable(USER_PASSWORD).send_keys('asd819hr1br12br18qQ')
	actor.wait_clickable(USER_PASSWORD).send_keys('{{ mysql_root_password }}')
	actor.wait_clickable(KEEP_AUTH_TO_ADMIN).click()
	actor.wait_clickable(LOGIN).click()
	logging.info('Login Ok')
	close_helper_check_and_close(b, actor)
	driver = b
	return driver

def close_helper_check_and_close(close_driver, actor):
	logging.info('close_helper_check_and_close start')
	logging.info('close_driver: {0}'.format(close_driver))
	logging.info('actor: {0}'.format(actor))
	close_sing_up_windows_status = actor.wait_visible_pass(SINGLE_LOGON_CLOSE_HELPER)
	logging.info('............................................................................')
	logging.info('close_sing_up_windows_status status {0}'.format(close_sing_up_windows_status))
	logging.info('............................................................................')
	if close_sing_up_windows_status is None:
		logging.info('............................................................................')
		logging.info('Button not finded, value is none')
		logging.info('............................................................................')
	else:
		logging.info('............................................................................')
		logging.info('Button finded:')
		logging.info('close_sing_up_windows_status: {0}'.format(close_sing_up_windows_status))
		logging.info('............................................................................')
		close_button_by_id_object = actor.wait_visible_pass(CLOSE_BUTTON_BY_ID)
		close_button_by_id_object.click()
		dont_show_checkbox = actor.wait_visible_pass(DONTSHOW_CHECKBOX)
		if dont_show_checkbox is None:
			logging.info('dont_show_checkbox not finded, value is none')
		else:
			logging.info('dont_show_checkbox finded, go click')
			dont_show_checkbox.click()
			close_button_by_id_object_dontshow = actor.wait_visible_pass(CLOSE_BUTTON_BY_ID)
			close_button_by_id_object_dontshow.click()
	logging.info('close_helper_check_and_close done')

def main():
	configure_logger()
	logging.info('Started')
	driver = login_to_admin()
	# PRINT RESULTS
	logging.info('BITRIX URL: {0}'.format(bitrix_url))
	logging.info('BITRIX IP: {0}'.format(bitrix_ip))
	logging.info('BITRIX URL ADMIN: {0}'.format(bitrix_url_admin))
	wait = WebDriverWait(driver, TIMEOUT)
	wait2 = WebDriverWait(driver, SLOWPOKE_TIMEOUT)
	actor = Actions(wait)
	actor2 = Actions(wait2)
	driver.get(site_edit_url)
	close_helper_check_and_close(driver, actor)
	frame = driver.find_element_by_class_name('adm-list-table') 
	logging.info('frame: {0}'.format(frame))
	links = frame.find_elements_by_xpath('.//*')
	for link in links:
		logging.info('...........................................')
		global indi_variable
		indi_variable = "Individ 15.4.2"
		_self_link_text = link.text
		if indi_variable in _self_link_text:
			global global_exclude_bitrix_sitecommunity
			global_exclude_bitrix_sitecommunity = "bitrix.sitecommunity"
			if global_exclude_bitrix_sitecommunity not in _self_link_text:
				logging.info('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
				logging.info('link: {0}'.format(link))
				logging.info('Big win: {0} link_text: {1}'.format(driver, link.text))
				logging.info('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
				actionChains = ActionChains(driver)
				actionChains.context_click(link).perform()
				install_click = actor.wait_visible(INDIVID_INSTALL_OBJECT)
				install_click.click()
				return True
				break
				sys.exit(0)
	logging.info('Finished')
	return True
	sys.exit(0)

if __name__ == "__main__":
	# execute only if run as a script
	main()