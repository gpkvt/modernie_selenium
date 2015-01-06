from selenium import webdriver

driver = webdriver.Remote("http://192.168.1.23:5555/wd/hub", webdriver.DesiredCapabilities.INTERNETEXPLORER.copy())
driver.get("http://www.google.com")
driver.get_screenshot_as_file('/Screenshots/google.png')
