function __simple_reencode_ssh_hosts
    if test -f ~/.ssh/config
        cat ~/.ssh/config | string match -v '^\s*#' | string match 'Host *' | string replace 'Host ' '' | string match -v '*\?' | string match -v '*\*' | string replace -r '$' ':'
    end
end

function __simple_reencode_local_paths
    set -l token (commandline -ct)
    set -l dir (string replace -r '[^/]*$' '' -- "$token")
    set -l partial (string replace -r '^.*/' '' -- "$token")

    test -z "$dir"; and set dir ./

    for entry in (command ls -1a "$dir" 2>/dev/null)
        string match -q "$partial*" -- "$entry"; or continue
        test "$entry" = "." -o "$entry" = ".."; and continue
        if test -d "$dir$entry"
            echo "$dir$entry"
        else
            echo "$dir$entry "
        end
    end
end

function __simple_reencode_remote_paths
    set -l token (commandline -ct)
    set -l parts (string split : -- $token)
    set -l host $parts[1]
    set -l rpath $parts[2]

    set -l dir (string replace -r '[^/]*$' '' -- "$rpath")
    set -l partial (string replace -r '^.*/' '' -- "$rpath")

    test -z "$dir"; and set dir ./
    string match -qv '*/'; and set dir "$dir/"

    ssh -o BatchMode=yes "$host" "ls -1F '$dir' 2>/dev/null" 2>/dev/null | while read -l entry
        set -l name (string replace -r '[/@*|=]$' '' -- "$entry")
        string match -q "$partial*" -- "$name"; or continue
        if string match -q '*/' -- "$entry"
            echo "$host:$dir$name"
        else
            echo "$host:$dir$name "
        end
    end
end

complete -c simple-reencode -n "__fish_seen_subcommand_from -amd -intel -nvidia" -x
complete -c simple-reencode -n "__fish_use_subcommand" -xa "-amd -intel -nvidia"

complete -c simple-reencode -n "! string match -q '*:*' -- (commandline -ct)" -a "(__simple_reencode_local_paths)"
complete -c simple-reencode -n "string match -q '*:*' -- (commandline -ct)" -a "(__simple_reencode_remote_paths)"

complete -c simple-reencode -n "! string match -q '*:*' -- (commandline -ct) && ! string match -q '*/*' -- (commandline -ct)" -a "(__simple_reencode_ssh_hosts)"
