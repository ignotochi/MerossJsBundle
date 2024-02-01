![ezcv logo](https://github.com/ignotochi/MerossJsBundle/blob/master/merossBundleInstallScriptExample.png)

# MerossJsBundle - 1.0.1

### What is it MerossJsBundle

This repository contains a bash script that allows you to clone the MerossApi and MerossJS repositories into two containers. The first one is a Python container, and the second one is inside an HTTPD container, using Docker Compose in both cases. The MerossJS container will be created only after compiling the source code, which is handled by the script.

### Requirements:

- Linux (tested on CentOS Stream 9)
- Docker
- Docker Compose (see: [https://docs.docker.com/compose/install](https://docs.docker.com/compose/install/linux/#install-using-the-repository))
- Npm (installed by the script if missing)
- Nvm (installed by the script if missing)
- The result will be two containers, MerossApi and MerossJS, exported on port 4449 and 8389, respectively.

If accessed from localhost, no additional action is required. Otherwise, you can set up a reverse proxy for both containers and reach them in the way you prefer.

Inside the MerossBundle folder, you will find a MerossJS folder, which contains a configuration file named merossApi.conf.json:

``` json 
{
    "language" : "it",            (default language used by frontend)
    "port": "4449",               (port of MerossApi server)
    "marossApiUrl": "localhost",  (url of MerossAPI server)
    "protocol": "https"           (protocol of MerossAPI server)
}
```

Modify it only if necessary, such as when the backend is exposed on an address other than localhost (default) or if you want to change the default language.

## How to install?

Navigate to your preferred installation directory and run:

```
git clone https://github.com/ignotochi/MerossJsBundle.git
```
In the root folder you will find a bash script called install.sh

Move there and run:

``` bash 
sh install.sh
```

This will clone the MerossApi and MerossJS repositories, and then the frontend in Angular will be compiled. If prompted to install npm and nvm, type Y.

After the procedure is complete, go into the merossJs folder and modify the merossApi.conf.json file if necessary, as mentioned earlier.

then open your brpwser and navigate to:

``` bash 
http://localhost:8389
```

Enjoy!



