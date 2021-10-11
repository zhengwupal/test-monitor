#main_pid=$(pgrep dockerd-current)
#echo "$main_pid"
# shellcheck disable=SC2046
#ps --forest $(ps -e --no-header -o pid,ppid|awk -vp="$main_pid" 'function r(s){print s;s=a[s];while(s){sub(",","",s);t=s;sub(",.*","",t);sub("[0-9]+","",s);r(t)}}{a[$2]=a[$2]","$1}END{r(p)}')
shim_pid=$(pgrep -f docker-containerd-shim-current)
#echo "$shim_pid"
# shellcheck disable=SC2046
for i in $shim_pid
do
{
    # shellcheck disable=SC2046
    shim_tree=$(ps --forest $(ps -e --no-header -o pid,ppid|awk -vp="$i" 'function r(s){print s;s=a[s];while(s){sub(",","",s);t=s;sub(",.*","",t);sub("[0-9]+","",s);r(t)}}{a[$2]=a[$2]","$1}END{r(p)}'))
#    echo "$shim_tree"
    shim_tree_pid=$(echo "$shim_tree" | sed 's/^ //g' | cut -d " " -f 1 | head -n 3 | tail -n 1)
#    echo "$shim_tree_pid"
    pcmp=$(ps --no-header -o pid,pcpu,pmem,cmd -g "$shim_tree_pid")
#    echo "$pcmp"

#    echo "$pcmp" | sed 's/^ //g' | sed 's/\s\+/ /g' | cut -d ' ' -f 2-3
    cm=$(echo "$pcmp" | sed 's/^ //g' | sed 's/\s\+/ /g' | cut -d ' ' -f 2-3 | awk '{sum1+=$1;sum2+=$2} END {print sum1,sum2}')
#    echo "$cm"

    ctime=$(date "+%Y-%m-%d %H:%M:%S")

    winfo=$(echo "$pcmp" | head -n 1 | awk -F ' ' '{print $NF}')
#    echo "$winfo"
    wtype=$(echo "$winfo" | cut -d "/" -f 3)
    wid=$(echo "$winfo" | cut -d "/" -f 4)
    wstep=$(echo "$winfo" | cut -d "/" -f 5 | cut -d "-" -f 2)

    sinfo=$(echo "$pcmp" | grep "commands" | awk -F ' ' '{print $NF}' | awk -F '/' '{print $NF}')
    sname=$(echo "$sinfo" | cut -d "." -f 1)
    shname=$(echo "$sinfo" | cut -d "." -f 2-)
    echo "$ctime $cm $wtype $wid $wstep $sname $shname"
} &
done
wait
