#!/bin/bash

SHELLFILE='largeShell.sh'

echo '#!/bin/bash' > $SHELLFILE
echo 'result=0' >> $SHELLFILE

for i in {0..1000000}; do
    echo '((result++))' >> $SHELLFILE
    echo 'echo $result' >> $SHELLFILE
done

chmod +x $SHELLFILE
