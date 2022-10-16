import openpyxl
import json
import time
import os
import traceback
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

EXCEL_NAME = 'pdf.xlsx'
EXCEL_SHEET_NAME = 'シート1'
DRIVER_PATH = './chromedriver'

def import_excel() -> dict:
    data = dict()
    workbook = openpyxl.load_workbook(EXCEL_NAME)
    sheet = workbook[EXCEL_SHEET_NAME]
    row = 2
    
    while True:
        id_num = sheet.cell(row=row, column=1).value
        if id_num == None:
            break
        else:
            hello_work_num = sheet.cell(row=row, column=2).value
            url = 'https://www.hellowork.mhlw.go.jp/kensaku/GECA110010.do?screenId=GECA110010&action=dispDetailBtn&kJNo=' + hello_work_num + '&kJKbn=1&jGSHNo=B5VtkNVFHYHEOTF5MdwAqQ%3D%3D&fullPart=2&iNFTeikyoRiyoDtiID=&kSNo=&newArrived=&tatZngy=1&shogaiKbn=0'
            data[id_num] = url
            row += 1
    return data

def create_pdf(data):
       
    # Setup Chrome options for prinr page as PDF
    chrome_option = webdriver.ChromeOptions()
    printer_config = {
        "recentDestinations": [
            {
                "id": "Save as PDF",
                "origin": "local",
                "account":""
            }
        ],
        "selectedDestinationId": "Save as PDF",
        "version": 2,
        "isLandscapeEnabled": True,
        "pageSize": 'A4',
        #"mediaSize": {"height_microns": 355600, "width_microns": 215900}, #紙のサイズ　（10000マイクロメートル = １cm）
        "marginsType": 0,
        "scalingType": 0,
        #"scaling": "141" ,#倍率
        "isHeaderFooterEnabled": False,
        "isCssBackgroundEnabled": True,
        "isDuplexEnabled": False,
        "isColorEnabled": True,
        "isCollateEnabled": True
    }
    
    prefs = {
        'printing.print_preview_sticky_settings.appState': json.dumps(printer_config),
        'download.default_directory': os.getcwd()
    }

    chrome_option.add_experimental_option('prefs', prefs)
    chrome_option.add_argument('--kiosk-printing')

    # Create PDF from each url website
    driver = webdriver.Chrome(executable_path=DRIVER_PATH, options=chrome_option)
    for key in data:
        url = data[key]
        driver.implicitly_wait(10)
        driver.get(url)
        WebDriverWait(driver, 15).until(EC.presence_of_all_elements_located)
        driver.execute_script('document.title="' + key + '";window.print();')
        time.sleep(1)
    driver.quit()

if __name__ == '__main__':
    try:
        data = import_excel()
        create_pdf(data)
    except:
        traceback.print_exc()
