BEGIN {
    flag = 0
    inserted = 0
    bracket = 0
    res = ""
    stay = ""
    # TARGET_PATH must exist and should be pre-defined via -v
    if (TARGET_PATH == "") {
        TARGET_PATH = "/usr/local/etc/nginx"
    }
    LOG = "/tmp/nginx.log"
}

/^[ \t]*server[ \t]*\{/ {
    flag = 1
    bracket = 1
    res = res $0 "\n"
    if (inserted == 0) {
        stay = stay "\tinclude " TARGET_PATH "/sites-enabled/*.conf;\n"
        inserted = 1
    }
    print NR $0 " // Server directive" > LOG #!!!
    next
}

{
    if (flag == 1) {
        res = res $0 "\n"
    } else {
        stay = stay $0 "\n"
    }
    print NR $0 " // Flag: " flag > LOG #!!!
}

/^[ \t]*server_name/ {
    server_name = $NF
    sub(/;/, "", server_name)
    gsub(/\.?\*\.?/, "_", server_name)
    if (server_name ~ /^(localhost|_)$/) {
        server_name = "default"
    }
    print NR $0 " // Server Name: " server_name > LOG #!!!
}

/listen/ {
    port = $2
    sub(/;/, "", port)
    gsub(/[:\[\]]+/, "ipv6_", port)
    print NR $0 " // Port: " port > LOG #!!!
}

/\}[ \t]*$/ {
    if (flag == 1) {
        bracket--
        if (bracket == 0) {
            flag = 0
            TRG = TARGET_PATH  "/sites-available/" server_name ".conf"
            print res > TRG
            res = ""
            server_name = ""
        }
    }
    print NR $0 " // Close bracket. Bracket: " bracket ", flag: " flag > LOG #!!!
}

/\{[ \t]*$/ {
    if (flag == 1) {
        bracket++
    }
    print NR $0 " // Open bracket. Bracket: " bracket > LOG #!!!
}

END {
    print stay
}
