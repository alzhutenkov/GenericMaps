#!/bin/bash

Help()
{
   # Display Help
   echo "🍿 Генерация типов карт 🥤"
   echo "⚠️  Синтаксис: [-h|m]"
   echo "Параметры:"
   echo "-m Перечисление типов карт через запятую без пробелов."
   echo "   ⛹️  Например: -m DGISMAPS,APPLEMAPS"
   echo "-h Список команд"
   echo
}

# Set variables
params=""

CreateConfig()
{
	path="$HOME/.genericConfig"

	if [ ! -d "$path" ]; then
    mkdir $path
	fi

	echo "Типы карт успешно сохранены $params"

	echo $params > "$path/GenericMaps.conf"
}

# Get the options
while getopts ":hm:" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      m) # Enter a params
         params=$OPTARG
         CreateConfig
         exit;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done
