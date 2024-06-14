#!/usr/bin/bash

function ipadmin {
<<<<<<< HEAD
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
        while true; do
                PS3="Wybierz opcje konfiguracyjna: "
                config_options=("1" "2" "3" "4" "5" "6")
                echo "1-ping 2-traceroute 3-ifconfig  4-ufw 5-netstat 6-powrot"

        select config_opt in "${config_options[@]}"; do
        case $config_opt in
                "1")
                check_iface
                read -p "Podaj adres do pingowania: " ping_addr
                sudo ping -I $iface -c 4 $ping_addr
                break
                ;;
                "2")
                check_iface
                read -p "Podaj adres do traceroute: " trace_addr
                sudo traceroute -i $iface $trace_addr
                break
                ;;
                "3")
                ifconfig
                break
                ;;
                "4")
                sudo ufw status
                break
                ;;
                "5")
                sudo netstat -tapen | more
                break
                ;;
                "6")
                break 2
                ;;
                *)
                echo "Podano zla wartosc, podaj wartosc z przedzialu 1-6"
                ;;
        esac
   done
done
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
=======
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
            echo "Przywracam poprzednie ustawienia sieci:"

            while read -r line; do
                if [[ $line =~ ^([a-zA-Z0-9]+):\ flags ]]; then
                    iface="${BASH_REMATCH[1]}"
                    [[ $iface == "lo" ]] && continue
                    echo "Znaleziono interfejs: $iface"
                elif [[ $line =~ inet\ ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+) ]]; then
                    ip="${BASH_REMATCH[1]}"
                    echo "Znaleziono adres IP: $ip"
                elif [[ $line =~ netmask\ ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+) ]]; then
                    netmask="${BASH_REMATCH[1]}"
                    echo "Znaleziono maskę sieci: $netmask"
                fi
            done < "$Network_backup"

            if [[ -n $iface && -n $ip && -n $netmask ]]; then
                sudo ifconfig "$iface" "$ip" netmask "$netmask"
                echo "Przypisano adres IP: $ip i maskę: $netmask do interfejsu: $iface"
            else
                echo "Błąd podczas przywracania ustawień interfejsu sieciowego."
            fi

            gateway=$(awk '/UG/{print $2}' "$Route_backup")
            if [[ -n $gateway ]]; then
                if ping -c 1 -W 1 "$gateway"; then
                    sudo route add default gw "$gateway"
                    echo "Przypisano bramę: $gateway"
                else
                    echo "Błąd: Brama $gateway jest nieosiągalna"
                fi
            else
                echo "Błąd podczas przywracania ustawień bramy"
            fi

            sudo cp "$Resolve_backup" /etc/resolv.conf
            echo "Przywrócono poprzednie ustawienia"
        else
            echo "Nie znaleziono plików backupu"
        fi
    }

    function sprawdzenie {
        if ping -c 3 www.google.pl; then
            echo "Ustawienia sieciowe są poprawne"
        else
            echo "Ustawienia sieciowe są niepoprawne, przywracam poprzednie ustawienia"
            przywroc
        fi
    }

    echo "Tworzenie katalogu do przechowywania wstępnych ustawień sieciowych backup"
    przypisanie_zmiennych

    echo "Dostępne interfejsy sieciowe"
    ifconfig -a
    echo "Dostępne interfejsy bezprzewodowe"
    iwconfig
    echo "Czy chcesz modyfikować ustawienia karty sieciowej? t/n"
    read x

    while [ "$x" == "t" ]; do
        PS3="Wybierz opcję: "
        options=("1" "2" "3" "4" "5")
        echo "1-przypisz manualnie 2-przypisz automatycznie 3-wyświetl informacje o ustawieniach sieciowych 4-przywróć poprzednie ustawienia 5-wyjdz"

        select opt in "${options[@]}"; do
            case $opt in
                "1")
                    podstawowe_dane
                    read -p "Podaj nazwę interfejsu: " iface
                    read -p "Podaj adres IP: " ip
                    read -p "Podaj maskę sieci: " mask
                    read -p "Podaj bramę: " gateway
                    read -p "Podaj DNS: " dns

                    # Sprawdź poprawność maski sieciowej
                    if [[ ! $mask =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
                        echo "Błędna maska sieciowa: $mask"
                        continue
                    fi

                    sudo ifconfig $iface $ip netmask $mask
                    sudo route add default gw $gateway
                    echo "nameserver $dns" | sudo tee /etc/resolv.conf
                    echo "Ręczne przypisanie ustawień IP dla $iface"
                    sprawdzenie
                    echo ""
                    break
                    ;;
                "2")
                    podstawowe_dane
                    read -p "Podaj nazwę interfejsu: " iface
                    sudo dhclient $iface
                    echo "Automatyczne przypisane ustawienia IP dla $iface"
                    sprawdzenie
                    echo ""
                    break
                    ;;
                "3")
                    echo "Aktualna konfiguracja interfejsów sieciowych: "
                    ifconfig
                    echo ""
                    echo "Tabela routingu: "
                    route -n
                    echo ""
                    echo "Aktualne ustawienia DNS: "
                    cat /etc/resolv.conf
                    echo ""
                    echo "Informacje o wszystkich połączeniach sieciowych: "
                    sudo netstat -a
                    echo ""
                    echo "Informacje o obecnie dostępnych połączeniach sieciowych, info o portach: "
                    sudo netstat -tapen | more
                    echo ""
                    break
                    ;;
                "4")
                    przywroc
                    echo "Przywrócono domyślne ustawienia sieciowe"
                    break
                    ;;
                "5")
                    echo "Usunięcie katalogu backup"
                    rm -rf "$Backup_dir"
                    echo "Do widzenia"
                    echo ""
                    exit 0
                    ;;
                *)
                    echo "Podano złą wartość, wybierz między 1-5"
                    echo ""
                    ;;
            esac
        done
    done
>>>>>>> 6550198 (Dziala ipadmin)
}

ipadmin
