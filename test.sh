echo "Czy chcesz uzyc programu (t/n)"
read z

while [ "$z" == "t" ]; do
    PS3="Wybierz opcje: "
    options=("1-Utworz uzytkownika zad.1" "2-Administrator kart sieciowych zad2." "3-Przenies pliki zad3." "4-Utworz baze danych zad.4" "5-Wyjdz")

    select opt in "${options[@]}"; do
        case $opt in
            "1-Utworz uzytkownika zad.1")
                grupy
                break
                ;;
            "2-Administrator kart sieciowych zad2.")
                ipadmin
                break
                ;;
            "3-Przenies pliki zad3.")
                mover
                break
                ;;
            "4-Utworz baze danych zad.4")
                baza
                break
                ;;
            "5-Wyjdz")
                echo "Wyjscie"
                exit 0
                ;;
            *)
                echo "Podano zla wartosc podaj wartosc z przedzialu 1-5"
                ;;
        esac
    done
done
