from selenium.webdriver.support import expected_conditions as ec
from selenium.common.exceptions import TimeoutException, NoSuchElementException

class Actions:
    def __init__(self, wait=20):
        self.wait = wait
        
    def wait_element_located(self, locator):
        try:
            return self.wait.until(ec.presence_of_element_located(locator))
        except:
            pass

    def wait_clickable(self, locator):
        try:
            return self.wait.until(ec.element_to_be_clickable(locator))
        except TimeoutException as e:
            e.msg = 'A timeout occured while waiting for element {} to be clickable'.format(locator)
            raise

    def wait_visible(self, locator):
        try:
            return self.wait.until(ec.visibility_of_element_located(locator))
        except TimeoutException as e:
            e.msg = 'A timeout occured while waiting for element {} to be visible'.format(locator)
            raise

    def wait_visible_pass(self, locator):
        try:
            return self.wait.until(ec.visibility_of_element_located(locator))
        except:
            pass