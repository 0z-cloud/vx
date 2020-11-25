import time
import os, luhn
import hashlib
import json
import yaml
from luhn import *
import re
from os.path import isfile, join
from plumbum import local
from mailer import Mailer
from time import gmtime, strftime

def md5sum(filename, blocksize=65536):
    if isfile(filename):
        #replaced = (filename.replace('!', ''))
        hash = hashlib.md5()
        with open(filename) as f:
                for block in iter(lambda: f.read(blocksize), b""):
                    hash.update(block)
    #hash = hashlib.md5()
    # with open(filename.replace('!', '/'), "rb") as f:
    #     for block in iter(lambda: f.read(blocksize), b""):
    #         hash.update(block)
        return str(hash.hexdigest())

import os.path, time

# pansearch_full_path = "{{ pansearch_full_path }}"
pansearch_full_path="/var/log"

catalogs_list = pansearch_full_path.split(' ')

#working_dir="/wrk/pansearch"
working_dir="./"

mask_finded_results = False  
scanning_only_gz = False #"{{ PANSEARCH_SCANNING_ONLY_GZ }}" 
unzip_before = False
send_email_with_results = True 
write_pan_to_log = False 
write_cvv_to_log = True 
current_hostname = local.get("hostname")()

stoplist = ["pareq","pares","audispd","panHash","INT_REF","</MD>","a3=","irn"]
cc_validator = """4[0-9]{12}([0-9]{3})|[25][1-7][0-9]{14}|6(011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(0[0-5]|[68][0-9])[0-9]{11}|(2131|1800|35\d{3})\d{11}"""

scan_failed = { 1: "not running at this time", 2: "completed"}
scan_status = 0

overall_before_status_lock = join(working_dir, "pansearch.lock")

log_file = join(working_dir, "pansearch_scanning.log")
timestamp_file = join(working_dir, "pansearch_timestamp.conf")
files_to_current_scan = join(working_dir, "pansearch_files_to_scan.db")
pansearch_files_list = join(working_dir, "pansearch.db")

log_file_gz = join(working_dir, "pansearch_scanning.log.gz")
timestamp_file_gz = join(working_dir, "pansearch_timestamp.conf.gz")
files_to_current_scan_gz = join(working_dir, "pansearch_files_to_scan.db.gz")
pansearch_files_list_gz = join(working_dir, "pansearch.db.gz")

html_message_body = join(working_dir, "mail_data.txt")

# PERFOMANCE SETTINGS
def scan_folder(folfer_path):
    files = []
    print ("folfer_path: " + folfer_path)
    for r, d, f in os.walk(folfer_path):
        #print (d)
        for file in f:
            files.append(os.path.join(r, file))
    for file in files:
        #print(file)
        file_md5 = md5sum(file)
        #file_md5 = time.ctime(os.path.getmtime(file))
        #os.utime(file, (access_time, modification_time))
        #print (file_md5)
        #data['file_md5']=

        scan_folder_full_list.update({file_md5: file})

        #hash_file = ()
        #scan_folder_full_list.append(file)
        #[1]=2
        #scan_folder_full_list.update(file = hash_file )
        # update( {file' : 23} )
 	# return files
    # for f in scan_folder_full_list:
    #     print(f)
 	#all_files_paths = os.list(folfer_path) 
 	#basedirs = list(filter(lambda x:fnmatch.fnmatch(x, probe), basedirs1))
 	#all_files_paths =  #`(find  -printf '%p\n' | sed 's/ /\\ /g')`

def build_queue(files_list):
	return queue

def process_queue(queue):
	
	data_map = {
	total_exec_time_mins:0,
	total_exec_time_secs:0,
	end_time:0,
	start_time:0,
	scan_overall_result:0,
	overall_before_status:0
	}
	start_datetime = strftime("%Y-%m-%d-%r", gmtime())
	start_timestamp = time.time()
	print(start_datetime)

	print(data_map)

	return data_map

def render_template():
	html_template = """<html>
    <body>
        <div>
            <p>Hello, Admins! PANSEARCH Scan scan_status, </p>
            <p>Please see the logs files attached</p>
            <p>----------------------------------</p>
            <p>BEFORE STATUS: $overall_before_status</p>
            <p>----------------------------------</p>
            <p>SCAN STATUS: $scan_overall_result</p>
            <p>----------------------------------</p>
            <p>----------------------------------</p>
            <p>START TIME: $start_time</p>
            <p>----------------------------------</p>
            <p>END TIME: $end_time</p>
            <p>----------------------------------</p>
            <p>TOTAL in mins: total_exec_time_mins ; TOTAL in secs: $total_exec_time_secs</p>
            <p>Have a nice day!</p>
            <p>With best regards,</p>
            <p>PANSEARCH Cron Job</p>
        </div>
    </body>
    </html>"""

	html_report_file = "message.html"
	return

def send_report():
	MAILING_USER = "pansearch-scanner@vortex.com"
	mailhost_ipv4 = "10.16.131.51"
	smtp_port = 25
	MAILING_HOSTNAME_URI = "smtp://{}:{}".format(mailhost_ipv4, smtp_port)
	MAILING_DESTINATION = "pci-devops@vortex.com"
	verify('356938035643809')
	sender = Mailer(mailhost_ipv4, port=20)

# 
def main():
    # print(pansearch_files_list_gz)
    global pansearch_files_list_array
    global scan_folder_full_list
    global scan_folder_full_list_json_db
    scan_folder_full_list = {}
    scan_folder_full_list_json_db = {}
    pansearch_files_list_array = {}

    if isfile(pansearch_files_list):
        print("We already have db, load to RAM done") 
        with open(pansearch_files_list) as f:
            json_object = json.load(f)
            scan_folder_full_list_json_db  = json.loads(json_object)
        print("Load to RAM done") 

    else:
        print("no have db")

    for dir_to_scan in catalogs_list:
        print ("dir to scan: " + dir_to_scan)
        scan_folder(dir_to_scan)

    scan_folder_full_list_json = json.dumps(scan_folder_full_list, indent=4, separators=(',', ': '))

    with open(pansearch_files_list, 'w') as outfile:
        json.dump(scan_folder_full_list_json, outfile, sort_keys=True, indent=4)

    # for i in scan_folder_full_list.keys():
    #     print (i)

    # for i in scan_folder_full_list_json_db.keys():
    #     print (i)

    if scan_folder_full_list_json_db:

        for i in scan_folder_full_list.keys():

            if i in scan_folder_full_list_json_db.keys():
            # if scan_folder_full_list_json_db[i]:
                print ("dbmd5: " + i)
                #print (scan_folder_full_list.keys())
            else:

                print ("no match md5: " + i)
                print ("no: " + scan_folder_full_list[i])
                #pansearch_files_list_array.update({[i]: scan_folder_full_list[i]})
                with open(files_to_current_scan, "a") as files_to_scan:
                    files_to_scan.write(scan_folder_full_list[i] + "\n")                
            
            #print (pansearch_files_list_array)
                    #files_to_current_scan.append(scan_folder_full_list[i])
    
    with open(files_to_current_scan, 'r') as f:
        #si = 0
        for line in f:
            #i=(i+1)
            print (line)
            # with open(files_to_current_scan, 'r') as f:
            #     print (line)
            

if __name__ == '__main__':
    main()
    exit()