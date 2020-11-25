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
	to_file = handlers.RotatingFileHandler(filename='/tmp/selenium-uninstall.log', maxBytes=(1048576*5), backupCount=7)
	to_file.setFormatter(format)
	scriptlogger.addHandler(to_file)

global check_results_states
global global_object
global wanted_states

check_results_states = collections.defaultdict(list)

global_object = collections.defaultdict(list)

array_initial_target_modules_states = {
	 "iblock": 'installed',
	 "blog": 'installed',
	 "advertising": 'installed',
	 "catalog": "installed",
	 "ldap": "removed",
	 "sender": "removed",
	 "bizprocdesigner": "removed",
	 "photogallery": "removed",
	 "cluster": "removed",
	 "calendar": "removed",
	 "report": "removed",
	 "idea": "removed",
	 "mobileapp": "removed",
	 "lists": "removed",
	 "scale": "removed",
	 "forum": "removed", 
	 "conversion": "removed", 
	 "wiki": "removed"
	}

gone_one_initial_target_modules = {
	 "storeassist": "removed",
	 "bizproc": "removed",
	 "learning": "removed",
	 "vote": "removed",
	 "support": "removed",
	 "workflow": "removed"
	}

def install_form_for_iblock(driver):
	logging.info("Start install module iblock")
	click_to_id_name_button(driver, "form_for_iblock")
	wait_element_by_id(driver, "catalog")
	click_to_id_name_button(driver, "catalog")
	clear_and_insert_by_id(driver, "public_dir_c", "/upload/")
	click_to_name_button(driver, "inst")


def install_form_for_blog(driver, runloop, element_by_name, attempts_in, sleep):
	logging.info("Start install module blog")
	logging.info('attempts_in: {0} sleep: {1}'.format(attempts_in, sleep))
	logging.info('runloop: {0} element_by_name: {1}'.format(runloop, element_by_name))
	attempts = 1
	logging.info('attempts: {0}'.format(attempts))
	click_to_id_name_button(driver, runloop)
	while attempts < attempts_in:
		try:
			attempts += 1
			logging.info('attempt {0}'.format(attempts))
			wait_element_by_name(driver, element_by_name)
			click_to_name_button(driver, "install_public_s1")
			click_to_name_button(driver, element_by_name)
		except:
			attempts += 1
			logging.info('attempt {0}'.format(sleep))
			time.sleep(sleep)
			pass
	else:
		logging.info('something wrong')
	logging.info('while ended, {0} ='.format(attempts))


def refresh_admin_page(driver, bitrix_url_admin):
	logging.info("Start refresh admin page")
	main_page_context = driver.get(bitrix_url_admin)
	logging.info('main_page_context: {0}'.format(main_page_context))
	click_to_id_name_button(driver, "global_menu_marketPlace")
	wait_element_by_id(driver,"bx_top_panel_button_helper")
	return main_page_context


def calculate_current_status(driver, wanted_states):
	logging.info("Start calculating current modules satatus")
	logging.info('driver: {0} wanted_states: {1}'.format(driver, wanted_states))
	global check_results
	check_results = ""
	check_results = collections.defaultdict(list)
	for key, value in wanted_states.items():
		logging.info('module: {0} needed state: {1}'.format(key, value))
		check_xpath_module_contain_uninstall(driver, key)
	return check_results


def compare_values(wanted_states, check_results):
	logging.info("Start compare with check results")
	global global_checks_results
	global_checks_results = ""
	global_checks_results = collections.defaultdict(list)
	for service_object, service_value in wanted_states.items():
		for checked_object, checked_value in check_results.items():
			if service_object == checked_object:
				clean_step_one = str(checked_value).strip('[]')
				cleaned_checked_value_step_two = clean_step_one.strip('\'')
				if service_value == cleaned_checked_value_step_two:
					logging.info('...............................................')
					logging.info('We in 2st right place')
					logging.info('service_object: {0}'.format(service_object))
					logging.info('service_value: {0}'.format(service_value))
					logging.info('checked_object: {0}'.format(checked_object))
					logging.info('checked_value: {0}'.format(checked_value))
					global_checks_results[service_object].append("completed")
					logging.info('...............................................')
				else:
					logging.info('...............................................')
					logging.info('WANTED! state is need to be changed for service {0}'.format(service_value))
					logging.info('service_object: {0}'.format(service_object))
					logging.info('service_value: {0}'.format(service_value))
					logging.info('checked_object: {0}'.format(checked_object))
					logging.info('checked_value: {0}'.format(checked_value))
					logging.info('Its not right place, values of serivce state mismatch')
					logging.info('wanted: {0} checked: {1}'.format(service_value, checked_value))
					global_checks_results[service_object].append(service_value)
					logging.info('...............................................')
	logging.info('global_checks_results is: {0}'.format(global_checks_results))
	return global_checks_results


def perform_global_modules_run(driver, global_checks_results):
	logging.info("Start working with modules")
	for key, value in global_checks_results.items():
		_self_clean_one = str(value).strip('[]')
		_self = _self_clean_one.strip('\'')
		if _self == "completed":
			logging.info("Completed module key: {0}".format(key))
		else:
			logging.info("Need to change state of module: {0}".format(key))
			logging.info("We perform: {0}".format(_self))
			if _self == "installed":
				logging.info("we go install module: {0}".format(key))
				if key == "iblock":
					logging.info("Matched iblock install section")
					install_form_for_iblock(driver)
					logging.info("Module iblock installed successfull")
				elif key == "blog":
					logging.info("Matched blog install section")
					install_form_for_blog(driver, "form_for_blog", "inst", 10, 3)
					logging.info("Module blog installed successfull")
				elif key == "advertising":
					logging.info("Matched advertising install section")
					multiple_retry_find_by_id(driver, "form_for_advertising", "inst", 10, 3)
					logging.info("Module advertising installed successfull")
				elif key == "catalog":
					logging.info("Matched catalog install section")
					multiple_retry_find_by_id(driver, "form_for_catalog", "inst", 10, 3)
					logging.info("Module catalog installed successfull")
				else:
					logging.info("Default install module")
					module_bitrix_name = "form_for_" + key
					multiple_retry_find_by_id(driver, module_bitrix_name, "inst", 10, 3)
			elif _self == "removed":
				logging.info("we go remove module: {0}".format(key))
				logging.info("Default remove module start")
				module_bitrix_name = "form_for_" + key
				logging.info("Current service name: {0}".format(key))
				logging.info("module_bitrix_name service name: {0}".format(module_bitrix_name))
				if key == "conversion":
					logging.info("Current remove module conversion")
					click_xpath_module_contain_delete(driver, module_bitrix_name)
				elif key == "wiki":
					logging.info("Current remove module wiki")
					click_xpath_module_contain_back(driver, module_bitrix_name)
				elif key == "storeassist":
					logging.info("Current remove module storeassist")
					click_xpath_module_contain_back(driver, module_bitrix_name)
				elif key == "bizproc":
					logging.info("Current remove module bizproc")
					click_xpath_module_contain_uninstall(driver, module_bitrix_name)
				elif key == "bizprocdesigner":
					logging.info("Current remove module bizprocdesigner")
					click_xpath_module_contain_uninstall(driver, module_bitrix_name)
				elif key == "photogallery":
					logging.info("Current remove module photogallery")
					click_xpath_module_contain_uninstall_backlist(driver, module_bitrix_name)
				else:
					click_xpath_module_contain_uninstall(driver, module_bitrix_name)
					logging.info("Module {0} remove complete".format(key))
			else:
				logging.info("something unxpected: {0} {1}".format(key, _self))
	logging.info("we complete working with modules")


def click_xpath_module_contain_back(driver, modulename):
	logging.info('driver: {0} modulename: {1}'.format(driver, modulename))
	request_path_main_element = (".//*[contains(@id, '{0}')]").format(modulename)
	logging.info('request_path_main_element: {0}'.format(request_path_main_element))
	request_path_second_element = ("//input[@name='uninstall']")
	logging.info('request_path_second_element: {0}'.format(request_path_second_element))
	request_to_xpath = '{0}{1}'.format(request_path_main_element, request_path_second_element)
	logging.info('request_to_xpath: {0}'.format(request_to_xpath))
	wait_element_by_xpath(driver, request_to_xpath)
	finded_element = driver.find_element(By.XPATH, request_to_xpath).click()
	logging.info('We perform delete finded_element: {0}'.format(finded_element))
	next_button = '//input[@value="Back to list" and @type="submit"]'
	wait_element_by_xpath(driver, next_button)
	finded_element_next_button = driver.find_element(By.XPATH, next_button).click()
	refresh_admin_page(driver, bitrix_url_admin)

def click_xpath_module_contain_delete(driver, modulename):
	logging.info('driver: {0} modulename: {1}'.format(driver, modulename))
	request_path_main_element = (".//*[contains(@id, '{0}')]").format(modulename)
	logging.info('request_path_main_element: {0}'.format(request_path_main_element))
	request_path_second_element = ("//input[@name='uninstall']")
	logging.info('request_path_second_element: {0}'.format(request_path_second_element))
	request_to_xpath = '{0}{1}'.format(request_path_main_element, request_path_second_element)
	logging.info('request_to_xpath: {0}'.format(request_to_xpath))
	wait_element_by_xpath(driver, request_to_xpath)
	finded_element = driver.find_element(By.XPATH, request_to_xpath).click()
	logging.info('We perform delete finded_element: {0}'.format(finded_element))
	next_button = '//input[@value="Remove" and @type="submit"]'
	wait_element_by_xpath(driver, next_button)
	finded_element_next_button = driver.find_element(By.XPATH, next_button).click()
	refresh_admin_page(driver, bitrix_url_admin)


def click_xpath_module_contain_uninstall_backlist(driver, modulename):
	logging.info('driver: {0} modulename: {1}'.format(driver, modulename))
	request_path_main_element = (".//*[contains(@id, '{0}')]").format(modulename)
	logging.info('request_path_main_element: {0}'.format(request_path_main_element))
	request_path_second_element = ("//input[@name='uninstall']")
	logging.info('request_path_second_element: {0}'.format(request_path_second_element))
	request_to_xpath = '{0}{1}'.format(request_path_main_element, request_path_second_element)
	logging.info('request_to_xpath: {0}'.format(request_to_xpath))
	wait_element_by_xpath(driver, request_to_xpath)
	finded_element = driver.find_element(By.XPATH, request_to_xpath).click()
	logging.info('We perform delete finded_element: {0}'.format(finded_element))

def click_xpath_module_contain_uninstall(driver, modulename):
	logging.info('driver: {0} modulename: {1}'.format(driver, modulename))
	request_path_main_element = (".//*[contains(@id, '{0}')]").format(modulename)
	logging.info('request_path_main_element: {0}'.format(request_path_main_element))
	request_path_second_element = ("//input[@name='uninstall']")
	logging.info('request_path_second_element: {0}'.format(request_path_second_element))
	request_to_xpath = '{0}{1}'.format(request_path_main_element, request_path_second_element)
	logging.info('request_to_xpath: {0}'.format(request_to_xpath))
	wait_element_by_xpath(driver, request_to_xpath)
	finded_element = driver.find_element(By.XPATH, request_to_xpath).click()
	logging.info('We perform delete finded_element: {0}'.format(finded_element))
	next_button = '//input[@name="inst" and @value="Delete module"]'
	wait_element_by_xpath(driver, next_button)
	finded_element_next_button = driver.find_element(By.XPATH, next_button).click()
	refresh_admin_page(driver, bitrix_url_admin)


def check_xpath_module_contain_uninstall(driver, modulename):
	logging.info('driver: {0} modulename: {1}'.format(driver, modulename))
	request_path_main_element = (".//*[contains(@id, '{0}')]").format(modulename)
	logging.info('request_path_main_element: {0}'.format(request_path_main_element))
	request_path_second_element = ("//input[@name='uninstall']")
	logging.info('request_path_second_element: {0}'.format(request_path_second_element))
	request_to_xpath = '{0}{1}'.format(request_path_main_element, request_path_second_element)
	logging.info('request_to_xpath: {0}'.format(request_to_xpath))
	try:
		finded_element = driver.find_element(By.XPATH, request_to_xpath)
		logging.info('finded_element: {0}'.format(finded_element))
		logging.info("module contain uninstall tag, no install again needed")
		check_results[modulename].append("installed")
		pass
	except:
		logging.info("module not installed")
		time.sleep(1)
		check_results[modulename].append("removed")
		pass
	logging.info('Completed block')

def multiple_retry_find_by_id(driver, runloop, element_by_name, attempts_in, sleep):
	logging.info('attempts_in: {0} sleep: {1}'.format(attempts_in, sleep))
	logging.info('runloop: {0} element_by_name: {1}'.format(runloop, element_by_name))
	attempts = 1
	logging.info('attempts: {0}'.format(attempts))
	click_to_id_name_button(driver, runloop)
	while attempts < attempts_in:
		try:
			attempts += 1
			logging.info('attempt {0}'.format(attempts))
			wait_element_by_id(driver, element_by_name)
			click_to_id_name_button(driver, element_by_name)
		except:
			attempts += 1
			logging.info('attempt {0}'.format(attempts))
			logging.info('sleep {0}'.format(sleep))
			time.sleep(sleep)
			pass
	else:
		logging.info('Something wrong')
	logging.info('Until complete, {0} ='.format(attempts))


def clear_and_insert_by_id(driver, element_by_name, send_key):
	logging.info('element_by_name: {0} class_name: {1}'.format(element_by_name, send_key))
	_self = driver.find_element_by_id(element_by_name)
	_self.clear()
	_self.send_keys(send_key)
	logging.info('_self: {0}'.format(_self))


def click_to_class_name_button(driver, class_name):
	logging.info("Started click element by CLASS NAME of CLASS_NAME")
	logging.info('driver: {0} class_name: {1}'.format(driver, class_name))
	try:
		login_button_find_and_click = driver.find_element_by_class_name(class_name).click()
		logging.info('login_button_find_and_click in first: {0}'.format(login_button_find_and_click))
	except StaleElementReferenceException:
		logging.info("StaleElementReferenceException")
		pass
	except SeleniumTimeoutException:
		logging.info("SeleniumTimeoutException")
		pass
	logging.info('Completed block')


def click_to_name_button(driver, class_name):
	logging.info("Started click element by NAME")
	logging.info('driver: {0} class_name: {1}'.format(driver, class_name))
	try:
		login_button_find_and_click = driver.find_element_by_name(class_name).click()
		submit_login_button_find_and_click = driver.find_element_by_name(class_name).submit()
		logging.info('login_button_find_and_click in first: {0}'.format(login_button_find_and_click))
	except SeleniumTimeoutException:
		logging.info("SeleniumTimeoutException")
		pass
	except:
		logging.info("StaleElementReferenceException")
		pass
	logging.info('Completed block')

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

def wait_element_by_id(driver, element):
	logging.info('driver: {0} element: {1}'.format(driver, element))
	try:
		wait = WebDriverWait(driver, 10)
		my_current_element = wait.until(EC.presence_of_element_located((By.ID, element)))
		logging.info('my_current_element: {0}'.format(my_current_element))
	except NoSuchElementException:
		time.sleep(2)
		logging.info('Not found element: {0}'.format(element))
		pass
	logging.info('element: {0}'.format(element))

def wait_element_by_name(driver, element):
	logging.info('driver: {0} element: {1}'.format(driver, element))
	try:
		wait = WebDriverWait(driver, 10)
		my_current_element = wait.until(EC.presence_of_element_located((By.NAME, element)))
		logging.info('my_current_element: {0}'.format(my_current_element))
	except:
		time.sleep(2)
		logging.info('Not found element: {0}'.format(element))
		pass
	logging.info('element: {0}'.format(element))

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

def clear_and_insert_by_name(driver, element_by_name, send_key):
	logging.info('element_by_name: {0} class_name: {1}'.format(element_by_name, send_key))
	_self = driver.find_element_by_name(element_by_name)
	_self.clear()
	_self.send_keys(send_key)
	logging.info('_self: {0}'.format(_self))


def click_to_element_if_exists_by_class_name(driver, element):
	logging.info('click_to_element_if_exists_by_class_name: start')
	logging.info('driver: {0} element: {1}'.format(driver, element))
	attempts = 1
	attempts_in = 5
	logging.info('attempts: {0}'.format(attempts))
	while attempts < attempts_in:
		try:
			wait = WebDriverWait(driver, 3)
			_self_element = wait.until(EC.presence_of_element_located((By.CLASS_NAME, element)))
			_self_button = driver.find_element_by_class_name(element).click()
			logging.info('_self_element: {0}'.format(_self_element))
			logging.info('_self_button: {0}'.format(_self_element))
			attempts += 1
		except:
			attempts += 1
			logging.info('attempt {0}'.format(attempts))
			logging.info("Close not found ")
			pass
	else:
		logging.info('Something wrong')
	logging.info('Completed block')

def click_to_element_if_exists_by_name(driver, element):
	logging.info('click_to_element_if_exists_by_name: start')
	logging.info('driver: {0} element: {1}'.format(driver, element))
	attempts = 1
	attempts_in = 5
	logging.info('attempts: {0}'.format(attempts))
	while attempts < attempts_in:
		try:
			wait = WebDriverWait(driver, 3)
			_self_element = wait.until(EC.presence_of_element_located((By.NAME, element)))
			_self_button = driver.find_element_by_name(element).click()
			logging.info('_self_element: {0}'.format(_self_element))
			logging.info('_self_button: {0}'.format(_self_button))
			attempts += 5
		except:
			attempts += 5
			logging.info('attempt {0}'.format(attempts))
			logging.info("Close not found")
			pass
	else:
		logging.info('Something wrong')
	logging.info('Completed block')

# MAIN SETTINGS

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

def refresh_admin_page(driver, bitrix_url_admin):
	logging.info("Start refresh admin page")
	main_page_context = driver.get(bitrix_url_admin)
	logging.info('main_page_context: {0}'.format(main_page_context))
	click_to_id_name_button(driver, "global_menu_settings")
	wait_element_by_id(driver,"bx_top_panel_button_helper")
	return main_page_context

def login_to_admin():
	logging.info('Logger Ok')
	#bitrix_ip = "develop.toprussianbloggers.ru"
	global bitrix_ip
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
	b.get('http://{{ bitrixip.stdout }}/bitrix/admin/module_admin.php?lang=en')
	logging.info('Get Ok')
	password_status = actor.wait_visible_pass(USER_PASSWORD)
	logging.info('Password status {0}'.format(password_status))
	actor.wait_clickable(USER_LOGIN).send_keys('admin')
	actor.wait_visible(USER_PASSWORD).click()
	actor.wait_clickable(USER_PASSWORD).send_keys('{{ mysql_root_password }}')
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
	click_to_class_name_button(driver, "adm-main-menu-item-icon")
	click_to_id_name_button(driver, "global_menu_marketPlace")
	# I. Login
	calculate_current_status(driver, array_initial_target_modules_states)
	compare_values(array_initial_target_modules_states, check_results)
	perform_global_modules_run(driver, global_checks_results)
	calculate_current_status(driver, gone_one_initial_target_modules)
	compare_values(gone_one_initial_target_modules, check_results)
	perform_global_modules_run(driver, global_checks_results)
	### Done comparing modules state
	logging.info('Finished')
	return True
	sys.exit(0)

if __name__ == "__main__":
	# execute only if run as a script
	main()