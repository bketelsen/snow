#!/usr/bin/env bash
set -euo pipefail

# scp all the .zst files from the mkosi.output directory to the remote server
for file in mkosi.output/*.zst; do
    echo "Transferring $file to remote server..."
    scp "$file" bjk@10.0.1.47:/mnt/fast/snow/
done
for file in mkosi.output/*.manifest; do
    echo "Transferring $file to remote server..."
    scp "$file" bjk@10.0.1.47:/mnt/fast/snow/
done
for file in mkosi.output/*.raw; do
    echo "Transferring $file to remote server..."
    scp "$file" bjk@10.0.1.47:/mnt/fast/snow/
done
for file in mkosi.output/*.efi; do
    echo "Transferring $file to remote server..."
    scp "$file" bjk@10.0.1.47:/mnt/fast/snow/
done

for file in mkosi.output/*.SHA256SUMS; do
    echo "Transferring $file to remote server..."
    scp "$file" bjk@10.0.1.47:/mnt/fast/snow/
done

echo "Transfer complete."
echo "Cleaning up releases on remote server..."

# get a list of all releases on the remote server
releases=$(ssh bjk@10.0.1.47 "ls /mnt/fast/snow/v*.SHA256SUMS || true")

# keep only the last 3 releases
releases_to_delete=$(echo "$releases" | sort -V | head -n -3)
if [[ -n "$releases_to_delete" ]]; then
    echo "Deleting old releases:"
    echo "$releases_to_delete"
    # for each file in releases_to_delete, cat the file to get the list of files to delete
    # the files are in the format "<sha256sum>  *<filename>"
    # we want to extract the filename and delete it from the remote server
    for release in $releases_to_delete; do
        echo "Processing $release"
        files_to_delete=$(ssh bjk@10.0.1.47 "cat $release" | awk '{print $2}' | sed 's/^\*//')
        for file in $files_to_delete; do
            echo "Deleting $file from remote server..."
            ssh bjk@10.0.1.47 "rm -f /mnt/fast/snow/$file"
        done
        echo "Deleting release file $release from remote server..."
        ssh bjk@10.0.1.47 "rm -f $release"
    done
fi

keep_releases=$(ssh bjk@10.0.1.47 "ls /mnt/fast/snow/v*.SHA256SUMS || true")
echo "Keeping these releases:"
echo "$keep_releases"

# move previous SHA256SUMS files to .old
ssh bjk@10.0.1.47 "mv /mnt/fast/snow/SHA256SUMS /mnt/fast/snow/SHA256SUMS.old || true"

# concatenate all the v*.SHA256SUMS files into a single SHA256SUMS file
ssh bjk@10.0.1.47 "cat /mnt/fast/snow/v*.SHA256SUMS > /mnt/fast/snow/SHA256SUMS"
