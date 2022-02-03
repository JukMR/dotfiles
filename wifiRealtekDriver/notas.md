### Solucion

Usar `iwctl` para conectarse a las redes. Habilitar el servicio `iwd` o `iwd.service` para que funcione iwctl. Además, deshabilitar `wpa_supplicant` reemplazandolo con iwd.

Es buena idea usar nmcli (networkmanager) como frontend junto con iwd.

iwctl se puede instalar del archivo iwd_1.5-1_amd64.deb que se encuentra en este directorio.

Instalarlo desde el repo de arch como iwd. Recordar habilitar el servicio con:

`sudo systemctl enable iwd.service`
