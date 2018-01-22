# DockerAndroidEmulator

An android emulator in docker

##How to use

`docker build -t android .
 && docker run
 -P
 --env EMULATOR=25
 --name android25
 --privileged 
 android 
`
