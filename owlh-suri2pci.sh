#!/bin/bash

# owlh-suri2pci.sh v.1.0
# 05.05.2018 @owlhnet 
# pci map management. append, modify or delete default map entries.
# main pci-map file : https://raw.githubusercontent.com/owlh/wazuhenrichment/master/pci_3.2.yaml

# NOTE: Sed command is ready for MAC OSx modify comments to allow Sed in other environments.

# TODOs
# append an existing SID - alert and abort
# Modify just one control in an existing SID: add or remove
# bulk file - use a file with multiple sids+pci_controls one pair per line. append, modify
# bulk file - use a feil with multiple sids to remove from map.
# bulk file - csv format


valc () {
    check="^[0-9.,]+$";
    if ! [[ $PCICONTROL =~ $check ]];then 
        return 1
    fi
}


vals () {
    check="^[0-9]+$";
    if ! [[ $SID =~ $check ]];then 
        return 1
    fi
}

printhelp () {
    echo "usage: com -a|ls|lc|m|d -s sid -c pci-controls -b bulk_file  pci_map_file"
    echo ""
    echo "      -a|--append       - append sid and pci-dss related controls to map file"
    echo "      -d|--delete       - sid and pci-dss related controls from map file"
    echo "      -ls|--listsid     - list pci controlers related with a sid or group of sids (grep)"
    echo "      -lc|--listctrl    - list sids that are associated with pci control"
    echo "      -m|--modify       - modify sid and pci mapping"
    echo "      -s|--sid          - sid number "
    echo "      -c|--control      - list of controls comma separated"
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
    -ls|--listsid)
    ACTION=LIST
    ACTIONTYPE=LISTSID
    shift # past argument
    ;;
    -lc|--listctrl)
    ACTION=LIST
    ACTIONTYPE=LISTCTRL
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
    if vals && valc; then
       printsid
       printcontrols
       echo $SIDCHAIN\: $CTRLCHAIN 
       echo $SIDCHAIN\: $CTRLCHAIN >> $MAPFILE
    fi
}

delete () {
    if vals; then
#      sed -i /$SID/d $MAPFILE
      sed -i '' /$SID/d $MAPFILE
    fi
}

modify () {
    delete
    append
}

list () {
    case $ACTIONTYPE in
      LISTSID)    
        grep $SID $MAPFILE 
      ;;
      LISTCTRL)    
        grep $PCICONTROL $MAPFILE 
      ;;
    esac
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



