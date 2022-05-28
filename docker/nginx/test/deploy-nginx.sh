#!/bin/bash

CONTENT=`curl http://169.254.169.254/latest/dynamic/instance-identity/document`

cat << EOF > index.html
<pre>${CONTENT}</pre>
EOF

docker run -itd --name nginx -p 80:80 nginx
docker cp index.html nginx:/usr/share/nginx/html/
