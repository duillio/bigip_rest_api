#!/bin/bash

CLUSTER_A_FRONT="192.168.0.41:8180 192.168.0.42:8180 192.168.0.43:8180 192.168.0.47:8180 192.168.0.48:8180"
CLUSTER_A_BACK="192.168.0.88:8180 192.168.0.89:8180"
CLUSTER_B_FRONT="192.168.10.201:8180 192.168.10.202:8180 192.168.10.203:8180 192.168.10.204:8180 192.168.10.209:8180"
CLUSTER_B_BACK="192.168.10.244:8180 192.168.10.245:8180"
POOLNAME="pool_back_unificado Pool_front_unificado"
BIGIPHOST="192.168.10.10 192.168.10.20"
if [ "$CLUSTERVIRAR" = B ]; then

    DESLIGA=$CLUSTER_A_FRONT
    DESLIGAR_BACK=$CLUSTER_A_BACK
    LIGAR_BACK=$CLUSTER_B_BACK
    LIGAR=$CLUSTER_B_FRONT
else
    DESLIGA=$CLUSTER_B_FRONT
    DESLIGAR_BACK=$CLUSTER_B_BACK
    LIGAR_BACK=$CLUSTER_A_BACK
    LIGAR=$CLUSTER_A_FRONT
fi

echo "========================================================================================================================================================================="
echo "#"
echo "# O Cluster Ativo é: $ATIVO e o inativo é: $INATIVO
                                                                                                                                                                               # "
echo "# o scritp vai executar ação de virado nos  BIGIP's: $BIGIPHOST                                                                                                                                                                          "
echo "# virando os seguintes pools: $POOLNAME                                                                                                                                  # "
echo "#"
echo "========================================================================================================================================================================="


echo "Desabilitando Cluster ATIVO:$ATIVO para INATIVO no BIGIP: $y "
echo
for z in $BIGIPHOST; do
        for y in $POOLNAME; do
            if [ "$y" == "pool_back_unificado" ]; then
                DESLIGA_LOOP=$DESLIGAR_BACK
            else
                DESLIGA_LOOP=$DESLIGA
             fi
        echo
        echo
        echo "Executando no stop  pool: $y do BIGIP: $z"
        echo
            for i in $DESLIGA_LOOP; do

                curl -k -u user_login:senha -X PUT https://$z/mgmt/tm/ltm/pool/~Common~$y/members/~Common~$i -H 'Accept: */*' -H 'Content-Type: application/json' -d '{ "state": "user-down", "session": "user-disabled" }'
                sleep 1

                echo
            done
        done
        echo
        echo "Finalizado stop pool $y"
        echo
        echo
        echo "Virando  Cluster INATIVO:$INATIVO para ATIVO no BIGIP: $y"
        echo
        echo

        for y in $POOLNAME; do
            if [ "$y" = "pool_back_unificado" ]; then
                LIGAR_LOOP=$LIGAR_BACK
            else
                LIGAR_LOOP=$LIGAR
            fi
        echo "Executando no start pool:$y do BIGIP: $z"
        for i in $LIGAR_LOOP; do
            curl -k -u user_login:senha -X PUT https://$z/mgmt/tm/ltm/pool/~Common~$y/members/~Common~$i -H 'Accept: */*' -H 'Content-Type: application/json' -d '{ "state": "user-up", "session": "user-enabled" }'
            sleep 1
        done
        echo
        echo
        echo "Finalizado Start pool $y"
        echo
    done
done
echo
echo "Finalizado script de virada bigip"