#!/bin/bash

my_user=''
link_odoo8='https://nightly.odoo.com/8.0/nightly/src/odoo_8.0.latest.tar.gz'
link_odoo10='https://nightly.odoo.com/8.0/nightly/src/odoo_8.0.latest.tar.gz'
link_odoo11='https://nightly.odoo.com/11.0/nightly/src/odoo_11.0.latest.tar.gz'


f_input_user(){
	if [ -z $my_user ];then	
		echo "###################################################"
		echo "Agregando usuario a entorno docker"
		echo "Ingrese usuario:"
		read my_user
	fi
}

f_install_odoo_docker(){
	f_check_dependency
	f_install_docker
	f_install_odoo
}

f_install_docker(){
	echo "##################################################"
	echo "Instalando Docker"
	apt-get remove docker docker-engine docker.io
	apt-get update
	apt-get install -y \
  	apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common -y
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

	my_fingerprint=$(apt-key fingerprint 0EBFCD88 | grep "9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88")
	if [ -z "$my_fingerprint" ]; then
		echo "error, fingerprint no encontrado"
	fi

	add-apt-repository \
  	"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
		$(lsb_release -cs) \
		stable"
	apt-get update
	apt-get install docker-ce -y

	docker run hello-world
	
	f_input_user
	my_group=$(cat /etc/group | grep docker)
	if [ -z "$my_group" ]; then
		groupadd docker	
	fi

	if [ -z "$(groups $my_user | grep docker)" ]; then
		usermod -aG docker $my_user
	fi

	echo "Para aplicar los cambios es necesario reiniciar el sistema"
	echo "Desar reiniciar ahora? s/n"
	read  response
	if [ $response == 's' ]; then
		shutdown -r now
	fi
}

f_install_odoo8(){
	echo "###################################################"
	f_input_user
	echo "Instalando docker-compose"
	apt-get install -y python-pip
	pip install docker-compose
	
	echo "##################################################"
	echo "Configurando odoo"
	sudo su $my_user -c "mkdir -p odoo/src odoo2"
	cd odoo2 && wget https://nightly.odoo.com/8.0/nightly/src/odoo_8.0.latest.tar.gz
	cd odoo2
	tar_odoo=$(ls)
	tar xvfz $tar_odoo
	for v in $(ls); do
		if [ $v != $tar_odoo ]; then
			mv $v/* ../odoo/src
		fi
	done
	cd ../ && rm -r odoo2
	sudo chown $my_user:$my_user -R odoo/src/*
	sudo su $my_user -c "mv .env docker-compose.yml Dockerfile ./odoo"
	sudo su $my_user -c "mv openerp-server.conf ./odoo/src"
	cd odoo

	echo "#################################################"
	echo "Build docker"
	docker-compose build
}

f_install_odoo11(){
	f_install_odoo $link_odoo11 odoo-server.conf
}

f_install_odoo(){	
	echo "###################################################"
	f_input_user
	echo "Instalando docker-compose"
	apt-get install -y python-pip
	pip install docker-compose
	
	echo "##################################################"
	echo "Configurando odoo"
	sudo su $my_user -c "mkdir -p odoo/src odoo2"
	cd odoo2 && wget $1
	cd odoo2
	tar_odoo=$(ls)
	tar xvfz $tar_odoo
	for v in $(ls); do
		if [ $v != $tar_odoo ]; then
			mv $v/* ../odoo/src
		fi
	done
	cd ../ && rm -r odoo2
	sudo chown $my_user:$my_user -R odoo/src/*
	sudo su $my_user -c "mv .env docker-compose.yml Dockerfile ./odoo"
	sudo su $my_user -c "mv $2 ./odoo/src"
	cd odoo

	echo "#################################################"
	echo "Build docker"
	docker-compose build
}

f_check_dependency(){
	echo "####################################################"
	echo "Verificando Dependencias"

	my_uname=$(uname -m)
	if [ $my_uname == 'x86_64' ]; then
		echo "x86_64 -> correcto"
	else
		echo "$my_uname -> incorrecto"
		exit
	fi

	my_version_number=('16.04' '16.10' '17.04')
	my_lsb=$(lsb_release -r)
	for mvn in $my_version_number; do
		my_var=$(echo $my_lsb | grep $mvn)
		if [ -n "$my_var" ];then
			echo "$mvn -> correcto"
			break
		fi
	done
	if [ -z "$my_var" ]; then
		echo "$my_lsb -> incorrecto"
	fi
}

f_error(){
	echo
	echo -e "\e[1;31m 		******* Opción invalida *******************"
	echo
	echo
	sleep 2
	f_main
}

f_main(){
	clear
	echo -e "\e[1;37m####################################################"
	echo -e "Construyendo infraestructura Yaroslab"
	echo -e "Bienvenido, Instalador Odoo-Docker"
	echo -e "####################################################"
	
	echo "1) Instalar DOCKER"
	echo "2) Verificar dependencias DOCKER"
	echo "3) Instalar ODOO 11"
	echo "4) Instalar ODOO 8"

	read my_opcion

	case $my_opcion in
		1)
			f_install_docker
			;;	
		2)
			f_check_dependency
			;;
		3)
			f_install_odoo11
			;;
		4)
			f_install_odoo8
			;;
		*)
			f_error
			;;
	esac
}

f_main
exit

