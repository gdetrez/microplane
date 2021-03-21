# !/bin/bash
#
# ./integration_test.sh
#
# This is a prototype end-to-end test for microplane.
#
# Please read carefully and use at your own risk.

if [ "$1" == "nuke" ]; then
  echo "nuking ./mp"
  rm -rf ./mp
fi

if [ -d "mp" ]; then
    echo "Working directory ./mp already exists. Please remove before running."
    exit 1
fi

tmpfile=$(mktemp /tmp/abc-script.XXXXXX)
echo "microplane-test/1" >> $tmpfile
echo "microplane-test/2" >> $tmpfile

echo "[Init]"
./bin/mp init -f $tmpfile

rm $tmpfile

echo "[Clone]"
./bin/mp clone
ts=`date +"%T"`

echo "TS = $ts"

echo "[Plan]"
./bin/mp plan -b plan -m "plan" -- sh -c "echo $ts >> README.md"

echo "[Push]"
./bin/mp push --throttle 2s -a nathanleiby

echo "[Merge]"
cmd='./bin/mp merge --throttle 2s --ignore-build-status --ignore-review-approval'
duration=10
until $cmd; do
    echo "waiting a bit ($duration seconds) so PRs are mergeable..."
    sleep $duration
done

