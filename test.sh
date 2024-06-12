#!/usr/bin/bash

function ipadmin {
        function przypisanie_zmiennych {
        Backup_dir="/tmp/network_backup"
        mkdir -p "$Backup_dir"
        Network_backup="$Backup_dir/network_backup.txt"
        Route_backup="$Backup_dir/route_backup.txt"
        Resolve_backup="$Backup_dir/resolve.conf.backup"
        }

        function podstawowe_dane {
        przypisanie_zmiennych
        ifconfig > "$Network_backup"
        route -n > "$Route_backup"
        cp /etc/resolv.conf "$Resolve_backup"
        }

        function przywroc {
         if [[ -f "$Network_backup" && -f "$Route_backup" && -f "$Resolve_backup" ]]; then
        echo "przywracam poprzednie ustawienia sieci: "


        while read -r line; do
        if [[ $line =~ ^([a-zA-Z0-9]+):\ flags ]]; then
                iface="${BASH_REMATCH[1]}"
        elif [[ $line =~ inet\ ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+) ]]; then
                ip="${BASH_REMATCH[1]}"
        elif [[ $line =~ netmask\ ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+) ]]; then
                netmask="${BASH_REMATCH[1]}"
        fi
        done < "$Network_backup"

        if [[ -n $iface && -n $ip && -n $netmask ]]; then
                sudo ifconfig "$iface" "$ip" netmask "$netmask"
        else
                echo "Blad podczas przywracania ustawien interfejsu siciowego."
        fi

        gateway=$(awk '/UG/{print $2}' "$Route_backup")
        if [[ -n $gateway ]]; then
                sudo route add defoult gw "$gateway"
        else
                echo "blad podczas przywracania ustawien bramy"
        fi

        sudo cp "$Resolve_backup" /etc/resolv.conf
        echo "przywrocono poprzednie ustawienia"
    else
        echo "nie znaleziono plikow backupu"
       fi
        }

        function sprawdzenie {
        if ping -c 3 www.google.pl ; then
          echo "Ustawienia sieciowe sa poprawne"
        else
          echo "Ustawienia sieciowe sa niepoprawne przywracam poprzednie ustawienia"
        przywroc
        fi  }

        echo "Tworzenie katalogu do przechowywania wstepnych ustawien sieciowych backup"
        przypisanie_zmiennych

  echo "Dostepne interfejsy sieciowe"
  ifconfig -a
  echo "Dostepne interfejsy bezprzewodowe"
  iwconfig
  echo "Czy chcesz modyfikowac ustawienia karty sieciowej? t/n"
read x

 while [ "$x" == "t" ] ; do
        PS3="Wybierz opcje: "
        options=("1" "2" "3" "4" "5")
        echo "1-przypisz manualnie 2-przypisz automatycznie 3-wyswietl informacje o ustawieniach sieciowych 4-przywroc poprzednie ustawienia  5-wyjdz"

 select opt in "${options[@]}"; do
 case $opt in
        "1")
        podstawowe_dane
         read -p "Podaj nazwe interfejsu: " iface
         read -p "Podaj adres IP:  " ip
         read -p "Podaj maske sieci: " mask
         read -p "Podaj brame: " gateway
         read -p "Podaj DNS: " dns

        sudo ifconfig $iface $ip netmask $mask
        sudo route add default gw $gateway
        echo "nameserver $dns" | sudo tee /etc/resolv.conf
        echo "reczne przypisanie ustawien IP dla $iface"
        sprawdzenie
         echo ""
 break
 ;;
        "2")
        podstawowe_dane
          read -p "Podaj nazwe interfejsu: " iface
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
        echo "informacje o wszystkich polaczeniach sieciowych: "
        sudo netstat -a
        echo ""
        echo "Informacje o obecnie dostepnych polaczeniach sieciowych, info o portach: "
        sudo netstat -tapen | more
        echo ""
 break
 ;;
        "4")
        przywroc
        echo "przywrocono domyslne ustawienia sieciowe"

 break
 ;;
        "5")
        echo "usuniecie katalogu backup"
        rm -rf "$Backup_dir"
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
