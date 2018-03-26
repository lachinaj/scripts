#!/bin/bash

_needed_commands="dialog";
_is_apt_update=false;

checkrequirements()
{
	command -v command >/dev/null 2>&1 || {
			echo "WARNING> \"command\" not found. Check requirements skipped!"
			return 1;
		}
	for requirement in ${_needed_commands} ; do
		echo -n "checking for \"$requirement\" ... " ;
		command -v ${requirement} > /dev/null && {
				echo "ok";
				continue;
		} || {
			if [ "${_is_apt_update}" = false ]; then
				apt-get update
				_is_apt_update=true
			fi
			apt-get install ${requirement} -y
			_return=1;
		}
	done
}

menu()
{
	cmd=(dialog --clear --backtitle "Install scripts" --title "Install" --menu "What do you want to do?" 20 100 20)
	options=("1" "OpenCV 3.3.1 L4T" 
		 "2" "Mono complete" 
		)
	choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

	valret=$?
	if [ $valret = 0 ]; then
		case $choices in
			1)
				clear
				./installOpenCV.sh
				;;
			2)
				clear
				./installMono.sh
				;;
		esac
	else
		clear
		echo "Install aborded"
		exit
	fi
}

checkrequirements
menu
