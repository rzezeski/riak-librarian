BEGIN {
    body="f"
    references="f"
    last_header="none"
}

/^From .* at .* [a-zA-Z]+ [a-zA-Z]+ [0-9]+ [0-9]{2}:[0-9]{2}:[0-9]{2} [0-9]{4}$/ {
    if (NR != 1) {
        printf "]]></body_t>\n</post>\n"
    }
    body="f"
    printf "<post>\n"
    next
}

body == "t" && last_header == "none" {
    gsub(/[\x01\x02\x03\x04\x05\x06\x07\x08\x0B\x0C\x0D\x0E\x0F\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1A\x1B\x1C\x1D\x1E\x1F]/, "", $0)
    print
    next
}

/^From: (.*) at (.*) \(.*\).*/ {
    print gensub(/^From: (.*) at (.*) \(.*\).*/, "<author_ws>\\1@\\2</author_ws>", $0)
    next
}

/^Date: (.*).*/ {
    print gensub(/^Date: (.*).*/, "<date_ig>\\1</date_ig>", $0)
    next
}

/^Subject: (.*)/ {
    last_header="]]></subject_t>"
    printf "%s\n", gensub(/^Subject: (.*)/, "<subject_t><![CDATA[\\1", $0)
    next
}

/^In-Reply-To: <(.*)>.*/ {
    if (last_header != "none") {
        printf "%s\n", last_header
        last_header="none"
    }
    print gensub(/^In-Reply-To: <(.*)>.*/, "<in_reply_to_s>\\1</in_reply_to_s>", $0)
    next
}

/^References\: <[^>]+>.*/ {
    if (last_header != "none") {
        printf "%s\n", last_header
        last_header="none"
    }

    gsub(/[<>]/, "", $0)
    gsub(/References: /, "<references_ws>", $0)
    # tmp=gensub(/^References: (.*)/, "<references_ws>\\1", $0)
    # print gensub(/[<>]/, "", "g", tmp)
    printf "%s", $0
    references="t"
    last_header="</references_ws>"
    next
}

/^Message-ID: <(.*)>.*/ {
    if (last_header != "none") {
        printf "%s\n", last_header
        last_header="none"
    }

    # if (references == "t") {
    #     printf "</references_ws>\n"
    #     references="f"
    # }
    print gensub(/^Message-ID: <(.*)>.*/, "<message_id_s>\\1</message_id_s>", $0)

    printf "<body_t><![CDATA["
    body="t"
    next
}

last_header == "</references_ws>" && body == "f" {
    gsub(/[\t]/, " ", $0)
    gsub(/[\t<>]/, "", $0)
    printf "%s", $0
    # print gensub(/[\t <>]/, "", "g", $0)
    # printf "%s", gensub(/[\t ]*<(.*)>.*/, " \\1", $0)9
    next

}

last_header == "]]></subject_t>" && body == "f" {
    print
    next
}

# body == "f" {
#     printf "<body_t><![CDATA[%s", $0
#     body="t"
#     next
# }


END {
    printf "]]></body_t>\n</post>\n"
}
