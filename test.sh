#!/bin/bash
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
        rm -f database.txt
    fi
}

baza
