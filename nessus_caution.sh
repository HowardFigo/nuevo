#!/bin/bash
echo "Ejecutar como root"
echo "Opciones:"
echo "(1) Mostrat plugins que se ejecutaron (peligrosos) -> Plugins_Logs_Caution.txt"
echo "(2) Deshabilitar (.nasl -> .nasl.old) plugins (peligrosos)"
echo "(3) Habilitar (.nasl.old -> .nasl) plugins (peligrosos)"
echo ""
echo "Peligrosos: ACT_DENIAL o DoS o Denial of Service"
echo ""
echo "Opción?: "
read N
if [ $N = 1 ]; then
	#Buscar los plugins que se ejecutaron en el logs de nessus
	cat /opt/nessus/var/nessus/logs/nessusd.messages | grep launching | grep -oiE '[a-z0-9._-]+nasl' | sort -u > Plugins_Logs.txt

	#Buscar los plugins que se ejecutaron en el logs de nessus con "ACT_DENIAL" y "DoS"
	for plugin in $(cat Plugins_Logs.txt) ; do
		if grep -r -e "ACT_DENIAL" -e "DoS" -ie "Denial of Service" /opt/nessus/lib/nessus/plugins/$plugin > /dev/null
		then echo $plugin >> Plugins_Logs_Caution.txt
		fi
	done;
	echo "Revisar el archivo Plugins_Logs_Caution.txt"
elif [ $N = 2 ]; then
	#Buscar los plugins con "ACT_DENIAL" , "DoS" y "Denial of Service"
	grep -r -e "ACT_DENIAL" -e "DoS" -ie "Denial of Service" /opt/nessus/lib/nessus/plugins/ | grep -oiE '[a-z0-9._-]+nasl' | sort -u > Plugins_Caution.txt

	for plugin in $(cat Plugins_Caution.txt) ; do
		mv /opt/nessus/lib/nessus/plugins/$plugin /opt/nessus/lib/nessus/plugins/$plugin.old
	done;
	service nessusd stop
	/opt/nessus/sbin/nessusd -R
 	service nessusd start
	echo "Se deshabilitaron los plugins (peligrosos)"
elif [ $N = 3 ]; then 
	ls /opt/nessus/lib/nessus/plugins/ | grep nasl.old > Plugins_Caution.txt
	for plugin in $(cat Plugins_Caution.txt) ; do
		mv /opt/nessus/lib/nessus/plugins/$plugin /opt/nessus/lib/nessus/plugins/${plugin%.*}
	done;
	service nessusd stop
	/opt/nessus/sbin/nessusd -R
 	service nessusd start
	echo "Se habilitaron los plugins (peligrosos)"
fi


