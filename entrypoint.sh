#!/bin/bash

if [[ $EMULATOR == "" ]]; then
    EMULATOR="25"
    echo "Using default emulator android $EMULATOR"
fi

echo EMULATOR  = "Requested API: ${EMULATOR} emulator."

if [[ -n $1 ]]; then
    echo "Last line of file specified as non-opt/last argument:"
    tail -1 $1
fi

# Run sshd
/usr/sbin/sshd

# Detect ip and forward ADB ports outside to outside interface
ip=$(ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')
socat tcp-listen:5037,bind=$ip,fork tcp:127.0.0.1:5037 &
socat tcp-listen:5554,bind=$ip,fork tcp:127.0.0.1:5554 &
socat tcp-listen:5555,bind=$ip,fork tcp:127.0.0.1:5555 &

#/usr/local/android-sdk/tools/bin/avdmanager create avd -f -n test -d 9 -k "system-images;android-23;google_apis;x86_64" -g google_apis -b "x86_64"
echo "no" | /usr/local/android-sdk/tools/bin/avdmanager create avd -f -n test -d 9 -k "system-images;android-${EMULATOR};google_apis;x86_64" -g google_apis -b "x86_64"
echo "no" | /usr/local/android-sdk/emulator/emulator -avd test -gpu host -use-system-libs -skin 1080x1920 -cores 4 -memory 3000 -partition-size 8192 -netfast -netspeed full -netdelay none -noaudio -no-window -verbose -qemu -usbdevice tablet
