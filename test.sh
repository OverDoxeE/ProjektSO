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
}

ipadmin
