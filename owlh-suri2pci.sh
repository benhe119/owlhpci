#!/bin/bash

# owlh-suri2pci.sh v.1.0
# 05.05.2018 @owlhnet 
# pci map management. append, modify or delete default map entries.
# main pci-map file : https://raw.githubusercontent.com/owlh/wazuhenrichment/master/pci_3.2.yaml

# TODOs
# append an existing SID - alert and abort
# Modify just one control in an existing SID: add or remove
# bulk file - use a file with multiple sids+pci_controls one pair per line. append, modify
# bulk file - use a feil with multiple sids to remove from map.
# bulk file - csv format


valc () {
    check="^[0-9.,]+$";
    if [[ $PCICONTROL =~ $check ]];then 
        echo PCICONTROL $PCICONTROL match;
    else
        echo PCICONTROL $PCICONTROL error; 
        return 1
    fi
}


vals () {
    check="^[0-9]+$";
    if [[ $SID =~ $check ]];then 
        echo SID $SID match;
        return 0
    else
        echo SID $SID error; 
        return 1
    fi
}

printhelp () {
    echo "usage: com -a|l|m|d -s sid -c pci-controls -b bulk_file  pci_map_file"
    echo "      -a|--append - append sid and pci-dss related controls to map file"
    echo "      -d|--delete - sid and pci-dss related controls from map file"
}

printsid () {
    SIDCHAIN="\"${SID}\""
}

printcontrols() {
    CTRLCHAIN="[\"${PCICONTROL//\,/\", \"}\"]"
}

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -s|--sid)
    SID="$2"
    if ! (vals); then 
      echo ERROR: SID $SID must be a number
      printhelp
      exit
    fi
    shift # past argument
    shift # past value
    ;;
    -c|--control)
    PCICONTROL="$2"
    if ! (valc); then 
      echo "ERROR: PCI CONTROLS $PCICONTROL must be a PCI requeriments (x or xx.xx) separated by commas without spaces"
      printhelp
      exit
    fi

    shift # past argument
    shift # past value
    ;;
    -b|--bulk)
    BULKFILE="$2"
    shift # past argument
    shift # past value
    ;;
    -a|--append)
    ACTION=APPEND
    shift # past argument
    ;;
    -l|--list)
    ACTION=LIST
    shift # past argument
    ;;
    -d|--delete)
    ACTION=DELETE
    shift # past argument
    ;;
    -m|--modify)
    ACTION=MODIFY
    shift # past argument
    ;;
    -h|--help)
    printhelp
    exit
    ;;
    *)    # unknown option
    MAPFILE+=("$1") # save it in an array for later
    if [[ ! -f $MAPFILE ]]; then 
       echo ERROR: PCI map file $MAPFILE does not exist.
       printhelp
       exit
    fi
    shift 
    ;;
esac
done

append () {
    echo append $SID, with controls $PCICONTROL to $MAPFILE
    echo cheking... 
    if vals && valc; then
       echo lets append it
       printsid
       printcontrols
       echo $SIDCHAIN\: $CTRLCHAIN 
       echo $SIDCHAIN\: $CTRLCHAIN >> $MAPFILE
    fi
}

delete () {
    echo delete $SID from map  $MAPFILE
    if vals; then
      sed -i '' /$SID/d $MAPFILE
    fi
}

modify () {
    echo modify $SID, with controls $PCICONTROL to $MAPFILE
    delete
    append
}

list () {
    echo list $SID, from $MAPFILE
    grep $SID $MAPFILE 
}

case $ACTION in
    APPEND)
    append
    ;;
    DELETE)
    delete
    ;;
    MODIFY)
    modify
    ;;
    LIST)
    list
    ;;
esac



