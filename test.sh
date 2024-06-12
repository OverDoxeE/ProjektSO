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
