#!/usr/bin/bash

function ipadmin {
        function iface_bool {
        local iface=$1
        if ip link show "$iface" > /dev/null 2>$1; then
        return 0
        else
         return 1
        fi
}
        function check_iface {
        while true; do
         read -p "Podaj nazwe interfejsu: " iface
        if iface_bool "$iface"; then
        echo "interfejs $iface  istnieje"
        break
        else
        echo "interfejs $iface nie istnieje prosze podac poprawny interfejs: "
        fi
    done
        }
        function sprawdzenie {
        if ping -c 3 www.google.com; then
          echo "Ustawienia sieciowe sa poprawne"
                return 0
        else
          echo "Ustawienia sieciowe sa niepoprawne brak polaczenia"
                return 1
        fi  }


  echo "Dostepne interfejsy sieciowe"
  ifconfig -a
  echo "Dostepne interfejsy bezprzewodowe"
  iwconfig
  echo "Czy chcesz modyfikowac ustawienia karty sieciowej? t/n"
read x

 while [ "$x" == "t" ]; do
        PS3="Wybierz opcje: "
        options=("1" "2" "3" "4" "5")
        echo "1-przypisz manualnie 2-przypisz automatycznie 3-wyswietl informacje o ustawieniach sieciowych 4-Uzyj funkcji konfiguracyjnych  5-wyjdz"

 select opt in "${options[@]}"; do
 case $opt in
        "1")
        check_iface
         read -p "Podaj adres IP:  " ip
         read -p "Podaj maske sieci: " mask
         read -p "Podaj brame: " gateway
         read -p "Podaj DNS: " dns
        sudo dhclient -r $iface
        sudo ifconfig $iface $ip netmask $mask
        sudo route add default gw $gateway
        echo "nameserver $dns" | sudo tee /etc/resolv.conf
        echo "reczne przypisanie ustawien IP dla $iface"
        if sprawdzenie; then
                echo "Poprawnie nadano ustawienia sieciowe"
        else
                echo "Nadaje ustawienia sieciowe automatycznie za pomoca DHCP:  "
                sudo dhclient $iface
                echo "ponownie weryfikuje polaczenie z siecia"
                ping -c 3 www.google.com
        fi
 break
 ;;
        "2")
          check_iface
        sudo dhclient -r $iface
        sudo dhclient $iface
        echo "Automatyczne przypisane ustawienia IP dla $iface"
        sprawdzenie
        echo ""
 break
 ;;
        "3")
         echo "aktualna konfiguracja inrerfejsow sieciowych: "
        ifconfig
        echo ""
        echo "tabela routingu: "
        route -n
        echo ""
        echo "aktualne ustawienia DNS: "
        cat /etc/resolv.conf
        echo ""
        echo "Informacje o obecnie dostepnych polaczeniach sieciowych, info o portach: "
        sudo netstat -tapen | more
        echo ""
 break
 ;;
        "4")
        echo "ping, traceroute, ipconfig, ufw, netstat, ifconfig "
 break
 ;;
        "5")
         echo "do widzenia"
        echo ""
     exit 0
 ;;
 *)
        echo "podano zla wartosc wybierz miedzy 1-5"
        echo ""
 ;;
   esac
 done
done
}

ipadmin
