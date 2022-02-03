### Solucion

Usar `iwctl` para conectarse a las redes. Habilitar el servicio `iwd` o `iwd.service` para que funcione iwctl. Además, deshabilitar `wpa_supplicant` reemplazandolo con iwd.

Es buena idea usar nmcli (networkmanager) como frontend junto con iwd.

iwctl se puede instalar del archivo iwd_1.5-1_amd64.deb que se encuentra en este directorio.

Instalarlo desde el repo de arch como iwd. Recordar habilitar el servicio con:

`sudo systemctl enable iwd.service`

==== StackNotes ====== 

Cambie el wpa_supplicant por el iw, capaz eso fue el problema. 

Ver: 
No, parece que funciono de suerte nomas. Pero habia conectado a la red 2.4

New edit 22/05 

El wpa_supplicant no es el problema, de ultima es el networkmanager.

un comando que funciona es conseguir una ip cuando ya estas conectado a la plaquita,
usando el comando:

sudo dhclient wlan0

donde wlan0 es el nombre de la interfaz de la placa wifi


*//////////////////////////////////////////////////////////*

Al final la posta era usar iwctl o iwd para manejar la placa y funciona como una luz






Text taken from:

https://askubuntu.com/questions/802205/how-to-install-tp-link-archer-t4u-driver


Works on Ubuntu 18.04.4 LTS with kernel head v5.3.xxx using this repo. which
you will need to git clone into a local folder

https://github.com/EntropicEffect/rtl8822bu

$ git clone https://github.com/EntropicEffect/rtl8822bu

Make sure you have build-essentials and dkms

$ sudo apt-get install build-essential dkms

After cloning, cd into that folder and run

$ cd rtl8822bu
$ make
$ sudo make install
$ sudo modprobe 88x2bu

Then connect to your Wi-Fi (Hopefully, both 2.4GHz and 5GHz should be
detectable now)

Next, follow these steps to refine the installation and for an automatic
rebuild on Ubuntu kernel image updates

$ sudo dkms add .
$ sudo dkms install -m 88x2bu -v 1.1

Lo solucione!!!

La solución fue usar iwctl para conectarme a la red

el paquete de instalacion de iwctl esta en la misma carpeta del driver

