# GenericMaps

Перечислять через ","
Возможные значения: "DGISMAPS,APPLEMAPS"

конфиг должен лежать по пути $HOME/.genericConfig/GenericMaps.conf

HOME - это environment переменная 
/Users/имяпользователя/.genericConfig/GenericMaps.conf

# Использование:
1. Можно использовать скрипт GenericMaps.sh

Или

2. 
* Добавить в `build settings` ключ `MAP_CONFIG` с параметрами `APPLEMAPS,DGISMAPS`

* И Build Phases добавить скрипт

``` bash
#!/bin/bash
path="$HOME/.genericConfig"

if [ ! -d "$path" ]; then
mkdir $path
fi

echo $MAPS_CONFIG > "$path/GenericMaps.conf"
```
