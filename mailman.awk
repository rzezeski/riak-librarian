# Convert mbox format into XML.
#
# http://en.wikipedia.org/wiki/Mbox
# http://tools.ietf.org/html/rfc4155
BEGIN {
    body="f"
    boundary="none"
    last_header="none"
    maybe_body="f"
    prep_body="f"
}

# The beginning of a message starts with 'From '
/^From .*/ {
    if (NR != 1) {
        printf "]]></body_t>\n</post>\n"
    }
    body="f"
    printf "<post>\n"
    next
}

# Found another boundry so this marks end of body.
body == "t" && /^--([0-9a-zA-z]+)/ {
    x = gensub(/^--(.*)/, "\\1", $0)
    if (x == boundary) {
        boundary="none"
        body="f"
        next
    }
}

# Remove non-printable characters from the body.
body == "t" && last_header == "none" {
    gsub(/[\x01\x02\x03\x04\x05\x06\x07\x08\x0B\x0C\x0D\x0E\x0F\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1A\x1B\x1C\x1D\x1E\x1F]/, "", $0)
    print
    next
}

# Extract the author.
/^From: (.*) at (.*) \(.*\).*/ {
    print gensub(/^From: (.*) at (.*) \(.*\).*/, "<author_ws>\\1@\\2</author_ws>", $0)
    next
}

# Extract the date it was sent.
/^Date: (.*).*/ {
    print gensub(/^Date: (.*).*/, "<date_ig>\\1</date_ig>", $0)
    next
}

# Extract the subject.
/^Subject: (.*)/ {
    last_header="]]></subject_t>"
    printf "%s\n", gensub(/^Subject: (.*)/, "<subject_t><![CDATA[\\1", $0)
    next
}

# Extract the message id it is in reply to.
/^In-Reply-To: <(.*)>.*/ {
    if (last_header != "none") {
        printf "%s\n", last_header
        last_header="none"
    }
    print gensub(/^In-Reply-To: <(.*)>.*/, "<in_reply_to_s>\\1</in_reply_to_s>", $0)
    next
}

# Extract messages it references.
/^References\: <[^>]+>.*/ {
    if (last_header != "none") {
        printf "%s\n", last_header
        last_header="none"
    }

    gsub(/[<>]/, "", $0)
    gsub(/References: /, "<references_ws>", $0)
    printf "%s", $0
    references="t"
    last_header="</references_ws>"
    next
}

# Extract the message id.
/^Message-ID: <(.*)>.*/ {
    if (last_header != "none") {
        printf "%s\n", last_header
        last_header="none"
    }

    print gensub(/^Message-ID: <(.*)>.*/, "<message_id_s>\\1</message_id_s>", $0)

    next
}

# If content-type with boundary exists then get boundary
/^Content-Type: .*boundary=(.*)/ {
    boundary = gensub(/^Content-Type: .*boundary=(.*)/, "\\1", $0)
    next
}

# Skip other headers.
/^[a-zA-Z][a-zA-Z\-]+: .*/ {
    next
}

# Continuation of a skipped header.
/ +/ && body == "f" {
    next
}

# Found boundary marker, this might be start of body.
/^--([0-9a-zA-z]+)/ {
    x = gensub(/^--(.*)/, "\\1", $0)
    if (x == boundary) {
        maybe_body="t"
    }
}

# Found the chunk that is in text/plain format
/^Content-Type: text\/plain.*/ && maybe_body == "t" {
    prep_body="t"
    next
}

# The body is delimited by blank line.
/^$/ && prep_body="t" {
    maybe_body="f"
    prep_body="f"
    last_header="none"
    body="t"
    printf "<body_t><![CDATA["
    next
}

# A continuation of References header.
last_header == "</references_ws>" && body == "f" {
    gsub(/[\t]/, " ", $0)
    gsub(/[\t<>]/, "", $0)
    printf "%s", $0
    next

}

# A continuation of Subject header.
last_header == "]]></subject_t>" && body == "f" {
    print
    next
}

# Start of body.
# body = "f" {
#     printf "<body_t><![CDATA["
#     body="t"
#     next
# }

END {
    printf "]]></body_t>\n</post>\n"
}
