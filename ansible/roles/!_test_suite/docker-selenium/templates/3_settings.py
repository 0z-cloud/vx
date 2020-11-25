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
	to_file = handlers.RotatingFileHandler(filename='/tmp/selenium-settings.log', maxBytes=(1048576*5), backupCount=7)
	to_file.setFormatter(format)
	scriptlogger.addHandler(to_file)

def clear_and_insert_by_id(driver, element_by_name, send_key):
	logging.info('element_by_name: {0} class_name: {1}'.format(element_by_name, send_key))
	_self = driver.find_element_by_id(element_by_name)
	_self.clear()
	_self.send_keys(send_key)
	logging.info('_self: {0}'.format(_self))

def click_to_id_name_button(driver, class_name):
	logging.info("Started click element by ID CLASS_NAME")
	logging.info('driver: {0} class_name: {1}'.format(driver, class_name))
	try:
		click_to_id_name_button_click = driver.find_element_by_id(class_name).click()
		logging.info('click_to_id_name_button_click in first: {0}'.format(click_to_id_name_button_click))
	except StaleElementReferenceException:
		logging.info("StaleElementReferenceException")
		pass
	except SeleniumTimeoutException:
		logging.info("SeleniumTimeoutException")
		pass
	logging.info('Completed block')

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

def click_xpath_module_set_template_path(driver, modulename):
	logging.info('driver: {0} modulename: {1}'.format(driver, modulename))
	request_path_template_path = (".//*[contains(@id, '{0}')]").format(modulename)
	logging.info('request_path_template_path: {0}'.format(request_path_template_path))
	request_path_template_second_element = ("//*[substring-after(name(), 'selected_type') = '']")
	next_button = '//option[@value="empty"]'
	logging.info('request_path_template_second_element: {0}'.format(request_path_template_second_element))
	request_to_xpath = '{0}{1}{2}'.format(request_path_template_path, request_path_template_second_element, next_button)
	logging.info('request_to_xpath: {0}'.format(request_to_xpath))	
	wait_element_by_xpath(driver, request_to_xpath)
	finded_element = driver.find_element(By.XPATH, request_to_xpath).click()
	logging.info('We perform delete finded_element: {0}'.format(finded_element))
	finded_element_next_button = driver.find_element(By.XPATH, request_to_xpath).click()

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

def login_to_admin():
	logging.info('Logger Ok')
	global bitrix_ip
	#bitrix_ip = "develop.toprussianbloggers.ru"
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
	site_edit_url = template_url_ip + "/bitrix/admin/site_edit.php?lang=en&LID=s1"
	logging.info('template_url: {0}'.format(template_url))
	password_status = actor.wait_visible_pass(USER_PASSWORD)
	logging.info('Password status {0}'.format(password_status))
	actor.wait_clickable(USER_LOGIN).send_keys('admin')
	actor.wait_visible(USER_PASSWORD).click()
	actor.wait_clickable(USER_PASSWORD).send_keys('asd819hr1br12br18qQ')
	#actor.wait_clickable(USER_PASSWORD).send_keys('{{ mysql_root_password }}')
	actor.wait_clickable(KEEP_AUTH_TO_ADMIN).click()
	actor.wait_clickable(LOGIN).click()
	logging.info('Login Ok')
	close_helper_check_and_close(b, actor)
	driver = b
	return driver


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
	main_site_name_selector = actor.wait_visible(MAIN_SITE_NAME)
	main_site_name_selector.clear()
	main_site_name_selector.send_keys("Top Russian Bloggers")
	main_domain_names_list = actor.wait_visible(MAIN_SITE_DOMAIN_NAMES)
	main_domain_names_list.clear()
	main_domain_names_list.send_keys("{{ ansible_main_site_name }}")
	web_site_name_set = actor.wait_visible(SITE_NAME)
	web_site_name_set.clear()
	web_site_name_set.send_keys("Top Russian Bloggers")
	server_name_set = actor.wait_visible(SERVER_NAME)
	server_name_set.clear()
	server_name_set.send_keys("{{ ansible_main_site_name }}")
	email_server_set = actor.wait_visible(MAIN_SITE_EMAIL)
	email_server_set.clear()
	email_server_set.send_keys("info@{{ ansible_main_site_name }}")
	click_xpath_module_contain_main(driver, "ID_HIDDENABLE_TR")
	click_xpath_module_set_template_path(driver, "ID_HIDDENABLE_TR")
	# driver.find_element_by_xpath('//*[@title="Path to file or folder"]').clear()
	# driver.find_element_by_xpath('//*[@title="Path to file or folder"]').send_keys("")
	save_button_click = actor.wait_clickable(SAVE_CURRENT_MENU_SETTINGS)
	save_button_click.click()
	logging.info('Finished')
	return True
	sys.exit(0)


if __name__ == "__main__":
	# execute only if run as a script
	main()