# Init
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
}

# 'server' block start
/^[ \t]*server[ \t]*\{/ {
    flag = 1
    bracket = 1
    res = res $0 "\n"
    if (inserted == 0) {
        stay = stay "\tinclude " TARGET_PATH "/sites-enabled/*.conf;\n"
        inserted = 1
    }
    next
}

# usual strings block
{
    if (flag == 1) {
        res = res $0 "\n"
    } else {
        stay = stay $0 "\n"
    }
}

# 'server_name' directive
/^[ \t]*server_name/ {
    server_name = $NF
    sub(/;/, "", server_name)
    gsub(/\.?\*\.?/, "_", server_name)
    if (server_name ~ /^(localhost|_)$/) {
        server_name = "default"
    }
}

# 'listen' directive
/listen/ {
    port = $2
    sub(/;/, "", port)
    gsub(/[:\[\]]+/, "ipv6_", port)
}

# Open bracket block
/\{[ \t]*/ {
    if (flag == 1) {
        bracket++
    }
}

# Closing bracket block
/\}[ \t]*/ {
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
}

# Print new nginx.conf
END {
    print stay
}
