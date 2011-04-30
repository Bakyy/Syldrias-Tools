@ECHO OFF
TITLE Préparation de la liste des entry a parser
COLOR 0A

:TOP
CLS
ECHO.
ECHO	### Preparation des fichiers necessaires aux différents parsers. ###
ECHO.
ECHO    Entrer vos information SQL
ECHO.
SET /p host= MySQL Server Address (e.g. localhost):
ECHO.
SET /p user= MySQL Username: 
SET /p pass= MySQL Password: 
ECHO.
SET /p world_db= World Database: 
SET port=3306
SET mysqlpath=.\mysql\

:Begin
CLS
%mysqlpath%\mysql -e "SELECT entry FROM locales_creature WHERE name_loc2 = ''" --host=%host% --user=%user% --password=%pass% --port=%port% %world_db% > ./creature_parse_entry.txt
%mysqlpath%\mysql -e "SELECT entry FROM locales_gameobject WHERE name_loc2 = ''" --host=%host% --user=%user% --password=%pass% --port=%port% %world_db% > ./gob_parse_entry.txt
%mysqlpath%\mysql -e "SELECT entry FROM locales_item WHERE name_loc2 = ''" --host=%host% --user=%user% --password=%pass% --port=%port% %world_db% > ./item_parse_entry.txt
%mysqlpath%\mysql -e "SELECT entry FROM locales_quest" --host=%host% --user=%user% --password=%pass% --port=%port% %world_db% > ./quest_parse_entry.txt
%mysqlpath%\mysql -e "SELECT entry FROM creature_template" --host=%host% --user=%user% --password=%pass% --port=%port% %world_db% > ./npc_vendor_entry.txt

PAUSE