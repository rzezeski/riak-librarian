# Convert mbox format into XML.
#
# http://en.wikipedia.org/wiki/Mbox
# http://tools.ietf.org/html/rfc4155
BEGIN {
    boundary = ""
    current_header = "none"
    end_tag = ""
    section = "headers"
}

# Every message starts with 'From '.
/^From .*/ {
    if (NR != 1) {
        # This is not the frist message and thus a previous message
        # has completed.
        printf "]]></body>\n</msg>\n"
    }
    section="headers"
    printf "<msg>\n"
    next
}

# Transitioned from headers to body.
section == "headers" && /^$/ {
    if (end_tag != "") {
        printf "%s\n", end_tag
    }
    end_tag = ""
    current_header = "none"
    if (boundary == "") {
        section = "body"
    } else {
        section = "multipart-search"
    }
    printf "<body><![CDATA["
}

# End of multiline header. Print end marker but continue processing
# line.
section == "headers" && /^[a-zA-Z].*: / && current_header != "none" {
    if (end_tag != "") {
        printf "%s\n", end_tag
    }
    end_tag = ""
    current_header = "none"
}

# If this is multipart need to grab boundary.
section == "headers" && match($0, /^Content-Type: .*boundary=(.*)/, m) {
    boundary = sprintf("--%s", m[1])
    next
}

# Extract the author.
section == "headers" && match($0, /^From: (.*)/, m) {
    # Try to extract real name instead of email.
    if (match(m[1], /.* at .* \((.*)\).*/, name)) {
        printf "<author>%s</author>\n", name[1]
    } else if (match(m[1], /(.*) <.*>.*/, name)) {
        printf "<author>%s</author>\n", name[1]
    } else {
        printf "<author>%s</author>\n", m[1]
    }
    next
}

# Extract the date.
section == "headers" && match($0, /^Date: (.*).*/, m) {
    # Remove day abbrev if present
    gsub(/[a-zA-Z]{3}, /, "", m[1])

    # Remove TZ abbrev if present
    gsub(/ \([A-Z]{3}\)/, "", m[1])

    if ( ("date -j -u -f '%e %b %Y %H:%M:%S %z' '" m[1] "' '+%Y-%m-%dT%H:%M:%SZ'" | getline iso) > 0) {
        printf "<date>%s</date>\n", iso
    } else {
        printf("ERROR: failed to parse date '%s'\n", m[1]) > "/dev/stderr"
    }
    next
}

# Extract the message id.
section == "headers" && match($0, /^Message-ID: <(.*)>.*/, m) {
    printf "<message_id>%s</message_id>\n", m[1]
}

# Extract subject.
section == "headers" && match($0, /^Subject: (.*)/, m) {
    current_header="subject"
    end_tag="]]</subject>"
    printf "<subject><![CDATA[%s", m[1]
    next
}

# Multi-line subject.
section == "headers" && current_header == "subject" {
    printf "%s\n", $0
    next
}

# Extract in reply to.
section == "headers" && match($0, /^In-Reply-To: <(.*)>.*/, m) {
    printf "<in_repl_to>%s</in_reply_to>\n", m[1]
    next
}

# Extract references
section == "headers" && match($0, /^References: <(.*)>.*/, m) {
    current_header="references"
    printf "<reference>%s</reference>\n", m[1]
    next
}

# Multiple references
section == "headers" \
&& current_header == "references" \
&& match($0, /.*<(.*)>.*/, m) {
    printf "<reference>%s</reference>\n", m[1]
    next
}

# Skip headers that aren't specified above.
section == "headers" {
    next
}

# This is a multipart message, need to search for text/plain section.
section == "multipart-search" && /^Content-Type: text\/plain.*/ {
    section = "multipart-header"
    next
}

# Transitioned from multipart body headers to body itself.
section == "multipart-header" && /^$/ {
    section = "multipart-body"
    next
}

section == "multipart-body" && $0 == boundary {
    section = "multipart-ignore"
    next
}

section == "multipart-ignore" {
    next
}

# Remove non-printable characters from the body.
section == "body" || section == "multipart-body" {
    gsub(/[\x01\x02\x03\x04\x05\x06\x07\x08\x0B\x0C\x0D\x0E\x0F\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1A\x1B\x1C\x1D\x1E\x1F]/, "", $0)
    print
    next
}
