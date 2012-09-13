#! /usr/bin/sed -nEf

# Remove first line, the pattern /From .* at/ is used as marker for
# end of post in this script.
1d

# The end of a post has been reached.  Print out the hold space which
# contains the body and close the post tag.
/From .* at/ {
                      i\
<body>
                      x
                      p
                      i\
</body>\
</post>
                      x
                      s/From .* at .*//
                      h
                      b breaknp
}

# The beginning of a new post and the content of the author field.
/^From: (.*) at (.*) \(.*\)$/ {
        i\
<post>
        s::<field name="author">\1@\2</field>:
        b break
        }

# Following are various email headers.
/^Date: (.*)$/ {
        s::<field name="date">\1</field>:
        b break
        }

/^Subject: (.*)$/ {
        s::<field name="subject">\1</field>:
        b break
        }

/^In-Reply-To: <(.*)>$/ {
        s::<field name="in_reply_to">\1</field>:
        b break
        }

/^References\: <(.*)>$/ {
        s::<field name="references">\1</field>:
        b break
        }

/^Message-ID: <(.*)>$/ {
        s::<field name="message_id">\1</field>:
        b break
        }

# If not an email header then it is body.  Collect the body in the
# hold space.
H
b breaknp

:break
p

:breaknp