num=1
bp=$(df | grep "ONCOBOX" | cut -d " " -f 1 | cut -d "/" -f 3)
b=$(echo "$bp" | cut -c 1-3)
while true; do
    #main_pid=$(pgrep dockerd-current)
    #echo "$main_pid"
    # shellcheck disable=SC2046
    #ps --forest $(ps -e --no-header -o pid,ppid|awk -vp="$main_pid" 'function r(s){print s;s=a[s];while(s){sub(",","",s);t=s;sub(",.*","",t);sub("[0-9]+","",s);r(t)}}{a[$2]=a[$2]","$1}END{r(p)}')
    shim_pid=$(pgrep -f docker-containerd-shim-current)
#    echo "$shim_pid"

    if [[ -n "$shim_pid" ]]; then
        num=1
        for i in $shim_pid; do
        {
            # shellcheck disable=SC2046
            shim_tree=$(ps --forest $(ps -e --no-header -o pid,ppid|awk -vp="$i" 'function r(s){print s;s=a[s];while(s){sub(",","",s);t=s;sub(",.*","",t);sub("[0-9]+","",s);r(t)}}{a[$2]=a[$2]","$1}END{r(p)}'))
#            echo "$shim_tree"
            shim_tree_pid=$(echo "$shim_tree" | head -n 3 | tail -n 1 | sed 's/^ //g' | cut -d " " -f 1)
            echo "$i ====== $shim_tree_pid"
            pcmp=$(ps --no-header -o pid,pcpu,pmem,cmd -g "$shim_tree_pid")
#            echo "$pcmp"

#            echo "$pcmp" | sed 's/^ //g' | sed 's/\s\+/ /g' | cut -d ' ' -f 2-3
            cm=$(echo "$pcmp" | sed 's/^ //g' | sed 's/\s\+/ /g' | cut -d ' ' -f 2-3 | awk '{sum1+=$1;sum2+=$2} END {print sum1,sum2}')
#            echo "$cm"

            winfo=$(echo "$pcmp" | grep "cromwell-executions" | grep "bash" | head -n 1 | awk -F ' ' '{print $NF}')
#            echo "$winfo"
            wtype=$(echo "$winfo" | cut -d "/" -f 3)
            wid=$(echo "$winfo" | cut -d "/" -f 4)
            wstep=$(echo "$winfo" | cut -d "/" -f 5 | cut -d "-" -f 2)

            sinfo=$(echo "$pcmp" | grep "commands" | awk -F ' ' '{print $NF}' | awk -F '/' '{print $NF}')
            sname=$(echo "$sinfo" | cut -d "." -f 1)
            shname=$(echo "$sinfo" | cut -d "." -f 2-)

            ctime=$(date "+%Y-%m-%d %H:%M:%S")
            tcpu=$(top -n 1 -b | head -n 3 | tail -n 1 | cut -d "," -f 1 | sed -r 's/%Cpu\(s\):(.*)us/\1/' | sed 's/ //g')
            tmem=$(free | head -n 2 | tail -n 1 | awk '{print ($2-$7)/$2*100}')
            bio=$(iostat -d -x -k 1 2 -p "$b" | grep "$bp" | tail -n 1 | awk -F ' ' '{print $NF}')

            echo "$ctime $tcpu $tmem $bio $cm $wtype $wid $wstep $sname $shname" >> test.log
        } &
        done
        wait
        sleep 2
    else
        if [[ "$num" -le 60 ]]; then
            blank_time=$(date "+%Y-%m-%d %H:%M:%S")
            echo "$blank_time" >> test.log
            sleep 2
        else
            break
        fi
        num=$(($num+1))
    fi
done