# DockerAndroidEmulator

An android emulator in docker

##How to use

`docker build -t android .
 && docker run
 -P
 --env EMULATOR=25
 --env DISPLAY=:0
 --volume /tmp/.X11-unix:/tmp/.X11-unix:rw
 --name android25
 --privileged 
 android 
`
