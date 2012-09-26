BEGIN {
    body="f"
    references="f"
}

/^From .* at/ {
    if (NR != 1) {
        printf "]]></body_t>\n</post>\n"
    }
    body="f"
    printf "<post>\n"
    next
}

body == "t" && references == "f" {
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

/^Subject: (.*).*/ {
    print gensub(/^Subject: (.*).*/, "<subject_t><![CDATA[\\1]]></subject_t>", $0)
    next
}

/^In-Reply-To: <(.*)>.*/ {
    print gensub(/^In-Reply-To: <(.*)>.*/, "<in_reply_to_s>\\1</in_reply_to_s>", $0)
    next
}

/^References\: <[^>]+>.*/ {
    gsub(/[<>]/, "", $0)
    gsub(/References: /, "<references_ws>", $0)
    # tmp=gensub(/^References: (.*)/, "<references_ws>\\1", $0)
    # print gensub(/[<>]/, "", "g", tmp)
    printf "%s", $0
    references="t"
    next
}

/^Message-ID: <(.*)>.*/ {
    if (references == "t") {
        printf "</references_ws>\n"
        references="f"
    }
    print gensub(/^Message-ID: <(.*)>.*/, "<message_id_s>\\1</message_id_s>", $0)
    next
}

references == "t" && body == "f" {
    gsub(/[\t]/, " ", $0)
    gsub(/[\t<>]/, "", $0)
    printf "%s", $0
    # print gensub(/[\t <>]/, "", "g", $0)
    # printf "%s", gensub(/[\t ]*<(.*)>.*/, " \\1", $0)9
    next

}

body == "f" {
    printf "<body_t><![CDATA[%s", $0
    body="t"
    next
}


END {
    printf "]]></body_t>\n</post>\n"
}
