#!/usr/bin/env bash
  
# first parameter is the path, which will be recursively searched for hosts files
INPUT=${1:-~/git/ansible-roles/}
# second parameter is output file
OUTPUT=${2:-/tmp/generated_ssh_config_`whoami`}
# search for files named "hosts"
FILES=$(find "$INPUT" -name hosts)
# exclude empty lines, comments and group names ("[" at the beginning of the line)
# take only records with dots: fqdns, ips. Remove `grep "\."` to search for entries without dots. Some group names maybe be also taken...
ALL_HOSTS=`for f in "$FILES"; do cat $f | grep -v "^$\|^\[\|^#\|^;" | grep "\." | sed 's/^[ ]*//g' | cut -d" " -f1; done`
  
touch $OUTPUT
  
unbracket() {
    # if there are brackets in hostname - expand first pair of them.
    # replace first [] with {}, use grep -o to cut only those curly braces, remove curly braces.
    # [0:9] -> {0:9} -> 0:9
    if [[ `echo $1 | grep -c "]"` -ne 0 ]];then
        local brackets=$(printf $1 | sed "s/\[/{/" | sed "s/]/}/" | grep -o "{.*}" | sed 's/[{}]//g')
        local start=$(printf $brackets | cut -d: -f1)
        local end=$(printf $brackets | cut -d: -f2)
        for i in `seq -w $start $end`; do
            # replace first square brackets with number
            local host=`printf $1 | sed "s/\[[0-9]*:[0-9]*\]/$i/"`
            # next iteration aka expand next pair of brackets
            unbracket $host
        done
    else
        # if there no brackets to expand - just format and print hostname
        printf "Host $1\n  HostName $1\n\n"
    fi
}
  
for metahost in $ALL_HOSTS; do
    unbracket $metahost >> $OUTPUT
done
  
echo "Your generated ssh config is here - $OUTPUT"
echo "There are $(grep ^Host $OUTPUT | sort | uniq | wc -l) unique hosts in this config."
echo "Check if it is correct and use \"cat $OUTPUT >> ~/.ssh/config\" to merge with your current config."