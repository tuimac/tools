import openpyxl
import traceback
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import json
import time

EXCEL_NAME = 'pdf.xlsx'
EXCEL_SHEET_NAME = 'シート1'

def _PrintSetUp():
    chopt=webdriver.ChromeOptions()
    appState = {
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
        #"marginsType": 0, #余白タイプ #0:デフォルト 1:余白なし 2:最小
        #"scalingType": 3 , #0：デフォルト 1：ページに合わせる 2：用紙に合わせる 3：カスタム
        #"scaling": "141" ,#倍率
        #"profile.managed_default_content_settings.images": 2,  #画像を読み込ませな
        "isHeaderFooterEnabled": False,
        "isCssBackgroundEnabled": True,
        #"isDuplexEnabled": False, #両面印刷 tureで両面印刷、falseで片面印刷
        #"isColorEnabled": True, #カラー印刷 trueでカラー、falseで白黒
        #"isCollateEnabled": True #部単位で印刷
    }
    
    prefs = {
        'printing.print_preview_sticky_settings.appState': json.dumps(appState),
        'download.default_directory': '.'
    }
    chopt.add_experimental_option('prefs', prefs)
    chopt.add_argument('--kiosk-printing')
    return chopt

def _main_WebToPDF(BlogURL):
    chopt = _PrintSetUp()
    driver_path = './chromedriver'
    driver = webdriver.Chrome(executable_path=driver_path, options=chopt)
    driver.implicitly_wait(10)
    driver.get(BlogURL)
    WebDriverWait(driver, 15).until(EC.presence_of_all_elements_located)
    driver.execute_script('return window.print()')
    time.sleep(1)
    driver.quit()

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
    for key in data:
        _main_WebToPDF(data[key])

if __name__ == '__main__':
    try:
        data = import_excel()
        create_pdf(data)
    except:
        traceback.print_exc()
