#!/bin/bash
#set -x
#trap read debug
#!/bin/bash
# init

newuser=bvargo
shopt -s extglob
shopt -s dotglob
scriptname="$(realpath $0)"
start="$(date +%s)"
abslog="/library/books/.share/absown/absown.log"

#!/bin/bash
# nb: the swp file that editscript relies on is provided by nano

editscript(){
  local scriptname script path swp; scriptname=$(realpath "$0" 2>/dev/null); script="${scriptname##*/}"; path="${scriptname%/*}"; swp="$path/.$script.swp"
     [[ ! -e "$swp" ]] && printf "\n\n%s\n\n" "$swp" && (/usr/bin/nano "$scriptname") && exit
     printf "\n%s is already being edited.\n%s exists; try fg or look in another window.\n" "$scriptname" "$swp"; exit ;}

pause(){ read -p "$*" ; }


changeattrib(){
    sudo chown "$newuser":media "$1"

#    sudo find "$1" ! -user "$newuser" ! -iname metadata.json -exec chown -R "$newuser":media "{}" \;
#    sudo find "$1" ! -group media -exec chown -R "$newuser":media "{}" \;

    sudo find "$1" \( ! -group media -o ! -user "$newuser" \) ! -iname "metadata.json" -exec chown -R "$newuser":media "{}" \;
    sudo find "$1" -type d ! -perm 775 -exec chmod 775 "{}" \;
    sudo find "$1" -type f ! -perm 644 -exec chmod 644 "{}" \; 				#remove go-w for everything
#    sudo find "$1" -iname "*.opus" -type f ! -perm 644 -exec chmod 644 "{}" \;
    sudo find "$1" -iname "*.jpg" -type f ! -perm 664 -exec chmod 664 "{}" \;  #g+w for covers
#    if compgen -G ./"metadata.json" > /dev/null; then sudo chown abs:media metadata.json; fi
#    sudo find "$1" -iname metadata.json ! -user abs -exec sudo chown abs:media {} \;
#    sudo find "$1" -iname metadata.json ! -user abs -o ! -group media -exec sh -c 'chown abs:media metadata.json; chmod 664 metadata.json' \;
     sudo find "$1" -iname metadata.json \( ! -group media -o ! -user abs \) -exec sh -c 'chown abs:media metadata.json; chmod 664 metadata.json' \;

}

changeattrib1(){
    printf 'DATE: %s\n PWD: %s\n ' "$(date)" "$(pwd)" |tee -a "$abslog"
    sudo find "$1" ! -user "$newuser" ! -iname metadata.json |tee -a "$abslog"
    sudo find "$1" ! -group media |tee -a "$abslog"
    sudo find "$1" -type d ! -perm 775 |tee -a "$abslog"
#    sudo find "$1" -type f ! -perm 664 |tee -a "$abslog"
    sudo find "*.opus" -type f ! -perm 644|tee -a "$abslog"
   find "$1" -iname metadata.json ! -user abs|tee -a "$abslog"
}


[[ "$1" == @(edit|e|nano|-e|-E) ]] && editscript

cd /library/books

for i in /library/books/@(audiobooks|collections|comedy|ebooks|meditation|periodicals|private|recovery|The\ Great\ Courses\ \&\ The\ Modern\ Scholar)
 do
    cd "$i"
    [[ "$(pwd)" == "/library/books/"* ]] && [[ "$1" == "-l" ]] && changeattrib1 "$i" && changeattrib "$i" || [[ "$(pwd)" == "/library/books/"* ]] && changeattrib "$i"
done

wall "$scriptname completed"

