#!/bin/bash
kolbyscore (){
declare -a kolby2=( 31 + 14 + 15 + 5 + 31 + 10 + 13 + 22 + 17 + 24 + 0 )
echo kolby2
}

holliscore () {
holli2=( 17 + 18 + 10 21 + 24 + 3 + 22 + 14 + 6 22  +33 )
echo holli2
}

compare (){

kolbytotal=$(kolbyscore)
hollitotal=$(holliscore)

if [[ $kolbytotal > $hollitotal ]]
then 
echo "kolby wins with a score of $kolbytotal!"
echo "HOLLI SUCKS!! $hollitotal"
else 
echo "holli wins with a score of $hollitotal"
echo "KOLBY SUCKS!!! $kolbytotal"
fi 
}

compare

