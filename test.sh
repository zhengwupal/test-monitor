bp=$(df | grep "ONCOBOX" | cut -d " " -f 1 | cut -d "/" -f 3)
b=$(echo "$bp" | cut -c 1-3)
num=1

function test1() {
    num=22
    tcpu=$(top -n 1 -b | head -n 3 | tail -n 1 | cut -d "," -f 1 | sed -r 's/%Cpu\(s\):(.*)us/\1/' | sed 's/ //g')
    tmem=$(free | head -n 2 | tail -n 1 | awk '{print ($2-$7)/$2*100}')
    bio=$(iostat -d -x -k 1 2 -p "$b" | grep "$bp" | tail -n 1 | awk -F ' ' '{print $NF}')
    echo "$tcpu $tmem $bio"
}

function test2() {
    echo "1323293330808403"
}

#并行无法改变全局变量
(test1 > t.tmp; echo "$num") & (test2 > o.tmp)
wait
ss=$(cat t.tmp)
cc=$(cat o.tmp)
echo "$ss $cc"
echo "$num"

# 全局变量
num2=11
echo "$num2"
function test3() {
    num2=88
#    echo "$num2"
}
test3
echo "$num2"