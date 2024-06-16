#!/usr/bin/bash
function grupy {
echo "Podaj ilosc uzytkownikow"
read x

for ((i=1; i<=x; i++))
do
sudo useradd  "user$i"
echo "user$i:password$i" | sudo chpasswd

echo "user$i" o hasle "password$i"  zostal utworzony.
done

y=$(($x/2))
sudo groupadd "studenci_informatyki"
sudo groupadd "studenci_etyki"

for((i=1; i<=(x/2); i++))
do
#sudo groupadd "studenci_informatyki"
sudo usermod -aG "studenci_informatyki" "user$i"
done
echo Uzytkownikow 1-$y przypisano do grupy Informatyka


for ((i=(y+1); i<=x; i++))
do
#sudo groupadd "studenci_etyki"
sudo usermod -aG "studenci_etyki" "user$i"
done
echo Uzytkownikow $y - $x przypisano do grupy Etyka

echo "Czy chciabys wyswietlic informacje o kontach? t/n"
read qa

ok="t"
no="n"

if [[ "$qa" == "$ok" ]]; then
echo "Lista uzytkownikow"
cut -d: -f1 /etc/passwd
echo ""

echo "informacje o uzytkownikach"
for ((j=1;j<=x;j++))
do
id user$j
done
echo ""

echo "Lista grup"
cut -d: -f1 /etc/group
echo ""

echo "informacje o grupach"
getent group studenci_informatyki
getent group studenci_etyki
elif [[ "$qa" == "$no" ]]; then
echo "wybrales nie"
else

echo "Nie udala sie"
fi
}

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
}

function mover {

 read -p "Podaj sciezke do poczatkowego folderu: " pierwszy_folder

 read -p "Podaj sciezke do docelowego folderu: " docelowy_folder

        if [ ! -d "$pierwszy_folder" ]; then
    echo "folder poczatkowy nie istnieje prosze podac poprawna sciezke"
        exit 1
        fi

        if [ ! -d "$docelowy_folder" ]; then
    echo "folder docelowy nie istnieje, tworzenie folderu $docelowy_folder."
        mkdir -p "$docelowy_foler"
        fi
        licznik=0
        echo "Podaj wzorzec pliqkow do przeniesienia (np. *.txt , plik?)"
        read pattern

        for file in "$pierwszy_folder"/$pattern; do
                if [ -f "$file" ]; then
                        mv "$file" "$docelowy_folder/"
                echo "Plik $(basename "$file") zostal przeniesiony do $docelowy_folder"
                ((licznik++))
         fi
     done
        if [ $licznik -gt 0 ]; then
                echo "Lacznie przenieniesiono $licznik plikow."
        else
                echo "Brak plikow zgodnych z wzorcem $pattern w folderze zrodlowym"
        fi
}

function baza {
    baza_danych() {

        read -p "podaj liczbe kolumn: " kolumny
        read -p "podaj liczbe wierszy (bez naglowka): " wiersze

        headers=()
        widths=()

        echo "Tworzenie naglowka bazy danych"
        for ((j=0; j<$kolumny; j++)); do
            read -p "Podaj nazwe dla kolumny $((j+1)): " header
            headers+=("$header")
            widths+=(${#header})
        done

                echo "${headers[*]}" | tr ' ' '|' > baza_danych.txt

        data=()

        echo "Tworzenie bazy danych"
        for ((i=0; i<$wiersze; i++)); do
            row=()
            for ((j=0; j<$kolumny; j++)); do
                read -p "Podaj ${headers[$j]} dla wiersza $((i+1)): " value
                row+=("$value")
                if [ ${#value} -gt ${widths[$j]} ]; then
                    widths[$j]=${#value}
                fi
            done
            data+=("$(IFS='|'; echo "${row[*]}")")
            echo "${row[*]}" | tr ' ' '|' >> baza_danych.txt
        done
    }

    wyswietl_baze() {

        wybrane_wiersze=("${!1}")
        wybrane_kolumny=("${!2}")

        for ((j=0; j<$kolumny; j++)); do
            if [[ " ${wybrane_kolumny[@]} " =~ " $j " ]]; then
                printf "%-${widths[$j]}s" "${headers[$j]}"
                if [ $j -lt $((kolumny-1)) ]; then
                    printf " | "
                fi
            fi
        done
        echo

        for row_index in "${wybrane_wiersze[@]}"; do
            IFS='|' read -r -a values <<< "${data[$((row_index-1))]}"
            for ((j=0; j<$kolumny; j++)); do
                if [[ " ${wybrane_kolumny[@]} " =~ " $j " ]]; then
                    printf "%-${widths[$j]}s" "${values[$j]}"
                    if [ $j -lt $((kolumny-1)) ]; then
                        printf " | "
                    fi
                fi
            done
            echo
        done
    }

    baza_danych
    echo "Baza danych utworzona."

    echo "czy chcesz wyswietlic cala baze danych? (t/n)"
    read odpRead
    if [ "$odpRead" == "t" ]; then
        wybrane_kolumny=($(seq 0 $((kolumny-1))))
        wybrane_wiersze=($(seq 1 $wiersze))
        wyswietl_baze wybrane_wiersze[@] wybrane_kolumny[@]
    fi

    echo "Czy chcesz wyswietlic wybrane wiersze i kolumny? (t/n)"
    read odpSel
    if [ "$odpSel" == "t" ]; then
        echo "Podaj numery wierszy do wyswietlenia (oddzielone spacja): "
        read -a wybrane_wiersze
        echo "Podaj numery kolumn do wyswietlenia (oddzielone spacja, zaczynajac od 0): "
        read -a wybrane_kolumny
        wyswietl_baze wybrane_wiersze[@] wybrane_kolumny[@]
    fi

    echo "czy chcesz usunac baze danych? (t/n)"
    read odpDel
    if [ "$odpDel" == "t" ]; then
        rm -f baza_danych.txt
    fi
}
echo "Czy chcesz uzyc programu (t/n)"
read z

while [ "$z" == "t" ]; do
PS3="Wybierz opcje: "
options=("1" "2" "3" "4" "5")
echo "1-Utworz uzytkownika zad.1" "2-Administrator kart sieciowych zad2." "3-Przenies pliki zad3." "4-Utworz baze danych zad.4" "5-Wyjdz"

select opt in "${options[@]"
case $opt in
        "1")
                grupy
        break
        ;;
        "2")
                ipadmin
        break
        ;;
        "3")
                mover
        break
        ;;
        "4")
                baza
        break
        ;;
        "5")
        echo "Wyjscie"
        exit 0
        ;;
        *)
        echo "Podano zla wartosc podaj wartosc z przedzialu 1-5"
        ;;
        esac
     done
done
