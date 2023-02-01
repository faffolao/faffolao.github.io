#!/bin/bash

# controllo se lo script è avviato con i permessi di root.
if [ "$EUID" -ne 0 ]
	then echo "Questo script richiede i permessi di root."
	exit
fi

# welcome screen.
echo "Procedura guidata di chroot."
echo

# ORDINE DELLE PARTIZIONI DA MONTARE
# 1 /
# 2 /home
# 3 /var
# 4 /boot
# 4.1 /boot/efi
home_required=false
var_required=false
boot_required=false
efi_required=false

# stampo una lista delle partizioni disponibili.
echo " Partizioni disponibili"
echo "========================"
echo

fdisk -l | grep /dev/

# richiedo la partizione di root e provo a montarla.
echo

while : ;do
	read -p "Inserire partizione Root (/): " root_part
	mount $root_part /mnt
	if [ $? -eq 0 ]; then
		# la partizione di root è stata montata. ora verifico che non ce ne siano da montare delle altre.
		if [ -z "$(ls -A /mnt/home)" ]; then home_required=true; fi
		if [ -z "$(ls -A /mnt/var)" ]; then var_required=true; fi
		if [ -z "$(ls -A /mnt/boot)" ]; then 
			boot_required=true
			if [ -z "$(ls -A /mnt/boot/efi)" ]; then efi_required=true; fi
		fi
		  
		# una volta controllate le partizioni richieste esco dal ciclo.
		break;
	else
		echo "Impossibile montare la partizione di Root - controllare che sia esistente, scritta correttamente e che non sia già montata in /mnt."
	fi
done

# se richiesto, chiedo la partizione di home e provo a montarla.
echo

if [ "$home_required" = true ]; then
	while : ;do
		read -p "Inserire partizione Home (/home): " home_part
		mount $home_part /mnt/home
		if [ $? -eq 0 ]; then
			break;
		else
			echo "Impossibile montare la partizione di Home - controllare che sia esistente, scritta correttamente e che non sia già montata in /mnt/home."
		fi
	done
fi

# se richiesto, chiedo la partizione di var e provo a montarla.
echo

if [ "$var_required" = true ]; then
	while : ;do
		read -p "Inserire partizione Var (/var): " var_part
		mount $var_part /mnt/var
		if [ $? -eq 0 ]; then
			break;
		else
			echo "Impossibile montare la partizione di Var - controllare che sia esistente, scritta correttamente e che non sia già montata in /mnt/var."
		fi
	done
fi

# se richiesto, chiedo la partizione di boot e provo a montarla.
echo

if [ "$boot_required" = true ]; then
	while : ;do
		read -p "Inserire partizione Boot (/boot): " boot_part
		mount $boot_part /mnt/boot
		if [ $? -eq 0 ]; then
			break;
		else
			echo "Impossibile montare la partizione di Boot - controllare che sia esistente, scritta correttamente e che non sia già montata in /mnt/boot."
		fi
	done
fi

# se richiesto, chiedo la partizione di efi e provo a montarla.
echo

if [ "$efi_required" = true ]; then
	while : ;do
		read -p "Inserire partizione EFI (/boot/efi): " efi_part
		mount $efi_part /mnt/boot/efi
		if [ $? -eq 0 ]; then
			break;
		else
			echo "Impossibile montare la partizione di EFI - controllare che sia esistente, scritta correttamente e che non sia già montata in /mnt/boot/efi."
		fi
	done
fi

# ora vado a montare tutti i file system virtuali.
for dir in /dev /proc /sys /run; do
	mount --bind $dir /mnt/$dir
	if [ $? -ne 0 ]; then
		echo "La partizione $dir non è stata montata correttamente."
	fi
done

# avvio il processo di chroot.
chroot /mnt

if [ $? -eq 0 ]; then
	echo "Chroot eseguito correttamente."
else
	echo "Errore: impossibile eseguire il chroot - codice di errore $?"
fi
