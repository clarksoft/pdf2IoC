#! /bin/bash
# script desarrollado por Jair Palma
# es necesario darle como variable de entrada el nombre del pdf a examinar.
# el motivo de este script inicialmente fue encontrar IPs que correspondieran al ISP de Telsur/GTD dentro de los
# listados de IoC del Csirt.gob de tal  forma de generar acciones correctivas si se daba el caso.
# para ejecutarlo es necesario contar con python3-pdfminer (apt-get install python3-pdfminer -y)
# probado en  Linux 4.4.0-18362-Microsoft #476-Microsoft Fri Nov 01 16:53:00 PST 2019 x86_64 GNU/Linux
# v 2.1 se configura paar que orgsfinal.txt se recree cada vez que se ejecuta el script, caso contrario revisaba IPs encontradas en ejecuciones pasadas.
# v 2.0 se agrega Censys como medio alternativo para cuando Shodan no tenga el dato buscado
# requiere pdf2txt 

# variables
shodankey="<shodan api key>"                 #this must to be added.
isp="<isp that we looking for>"

echo "[+] Pasando $1 a texto"
pdf2txt $1 >$1.txt
echo "[+] Extrayendo Ips de "$1".txt"
cat $1.txt | grep -oi "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"|sort -u> resultado.txt
echo "[+] Obteniendo ISP de cada IP"
echo $(date) $1 >orgsfinal.txt
for i in $(cat resultado.txt); do
org=$(curl -s "https://www.shodan.io/host/$i/raw?key=$shodankey" | strings | grep 'property">isp</td>' -A1 | tail -1 | cut -d\> -f2 | cut -d\< -f1 | sort -u);
org2=$(curl -s "https://censys.io/ipv4/$i" | grep Network -A2 | tail -1 | cut -d\> -f 2 | cut -d\< -f1);
echo "   [+] "$i $org $org2;
echo "[+] "$i $org $org2 >>orgsfinal.txt;
done
echo "[+] Revisando ISP interesantes"
count=$(cat orgsfinal.txt | egrep -i "$isp" | wc -l)
lista=$(cat orgsfinal.txt | egrep -i "$isp")
fecha=$(date +%y%m%d)
echo "[+] A revisar: $count Ips"
echo $lista
echo $lista >Reporte$fecha
echo [+] FINALIZADO
