#!/bin/bash

echo "Creazione Round Robin Data Base..."
rrdtool create net-test.rrd --step=20 DS:in:COUNTER:40:0:1000000000000000 DS:out:COUNTER:40:0:1000000000000000 RRA:AVERAGE:0.5:1:13

for ((i=1; i<=13; i++)) ; do
	
	echo "Misurazione numero $i in corso..."
	
	TIME1=`date +%s`	#prendo l'epoch iniziale
	#assegno alla variabile IN_PCKS il numero di pacchetti ricevuti dall'interfaccia di rete wlp1s0 (notare l'importanza del simbolo ` (che si fa premendo AltGr→+→') per effettuare l'assegnamento)
	IN_PCKS=`ifconfig wlp1s0 | grep -m 1 "RX"`

	echo ${IN_PCKS}

	OUT_PCKS=`ifconfig wlp1s0 | grep -m 1 "TX"`	#pacchetti trasmessi in uscita

	echo ${OUT_PCKS}

	BYTES_IN=${IN_PCKS##* bytes }
	BYTES_IN=${BYTES_IN%% (*}	#sottostringa con numero di bytes

	BYTES_OUT=${OUT_PCKS##* bytes }
	BYTES_OUT=${BYTES_OUT%% (*}	#sottostringa con numero di bytes

	rrdtool update net-test.rrd N:$BYTES_IN:$BYTES_OUT

	echo
	echo "DATA BASE INFOS:"
	
	rrdtool info net-test.rrd
	
	TIME2=`date +%s`	#prendo l'epoch finale
	
	echo "Attendo l'intervallo di circa 20 secondi per poi effettuare la misurazione $((i+1))..."
	
	echo
	
	TIME=$((TIME2-TIME1))
	TIME=$((20-TIME))
	sleep $TIME
done

echo "Produzione grafico delle statistiche..."

rrdtool graph net-test.png --end now --start end-260s --title "Bytes in and out from PC" --vertical-label "bytes" DEF:in=net-test.rrd:in:AVERAGE DEF:out=net-test.rrd:out:AVERAGE LINE:in#ff0000:'Bytes in' LINE:out#00ff00:'Bytes out'


