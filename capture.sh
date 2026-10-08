#!/usr/bin/env bash
# Ethical demo on our OWN loopback: capture local HTTP traffic (including a
# clear-text login POST) with tshark, so we can analyse it afterwards.
# No external host is ever touched. Run on Kali (or any Linux with tshark).
set -e
PCAP=captures/http-login.pcap
mkdir -p captures

echo "[*] starting capture on lo ..."
tshark -i lo -w "$PCAP" -a duration:10 >/dev/null 2>&1 &
CAP=$!
sleep 3

echo "[*] starting a local web server (127.0.0.1:8000) ..."
python3 -m http.server 8000 --bind 127.0.0.1 >/dev/null 2>&1 &
SRV=$!
sleep 1

echo "[*] generating traffic (a page view + a clear-text login POST) ..."
curl -s http://127.0.0.1:8000/ >/dev/null
curl -s -d "username=admin&password=Sup3rSecret123" http://127.0.0.1:8000/login >/dev/null

sleep 6
wait $CAP 2>/dev/null
kill $SRV 2>/dev/null
echo "[+] saved $PCAP  (open it in Wireshark, or analyse with tshark)"
