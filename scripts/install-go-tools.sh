#!/usr/bin/env bash

set -e

cd /tmp

wget "https://github.com/ssut/payload-dumper-go/releases/download/1.2.2/payload-dumper-go_1.2.2_linux_amd64.tar.gz"
tar -xvf payload-dumper-go_1.2.2_linux_amd64.tar.gz
rm -rf payload-dumper-go_1.2.2_linux_amd64.tar.gz

mv payload-dumper-go /usr/bin/payload-dumper-go

wget "https://github.com/tcnksm/ghr/releases/download/v0.16.0/ghr_v0.16.0_linux_amd64.tar.gz"
tar -xvf ghr_v0.16.0_linux_amd64.tar.gz
rm -rf ghr_v0.16.0_linux_amd64.tar.gz

mv ghr_v0.16.0_linux_amd64/ghr /usr/bin/ghr
rm -rf ghr_v0.16.0_linux_amd64

true
