#! /usr/bin/sed -nEf

# Remove first line, the pattern /From .* at/ is used as marker for
# end of post in this script.
1d

# The end of a post has been reached.  Print out the hold space which
# contains the body and close the post tag.
/From .* at/ {
                      i\
<body><![CDATA[
                      x
                      p
                      i\
]]></body>\
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
        s::<author>\1@\2</author>:
        b break
        }

# Following are various email headers.
/^Date: (.*)$/ {
        s::<date>\1</date>:
        b break
        }

/^Subject: (.*)$/ {
        s::<subject><![CDATA[\1]]></subject>:
        b break
        }

/^In-Reply-To: <(.*)>$/ {
        s::<in_reply_to>\1</in_reply_to>:
        b break
        }

/^References\: <(.*)>$/ {
        s::<references>\1</references>:
        b break
        }

/^Message-ID: <(.*)>$/ {
        s::<message_id>\1</message_id>:
        b break
        }

# If not an email header then it is body.  Collect the body in the
# hold space.
H
b breaknp

:break
p

:breaknp