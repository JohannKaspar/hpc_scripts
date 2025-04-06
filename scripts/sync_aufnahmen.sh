#!/bin/bash

# A script to move audio files from SharePoint, set permissions, 
# convert .aac files to .wav, and rename "gedicht" to "poem" in filenames.

# Define the target directory based on the current date
TARGET_DIR="/data/cephfs-1/work/groups/mittermaier/stimmaufnahmen/$(date +%Y-%m-%d)"

# Step 1: Move files from SharePoint to the target directory
echo "Moving files from SharePoint to $TARGET_DIR..."
rclone move sharepoint:/General/Export "$TARGET_DIR" --progress --delete-empty-src-dirs

# Entpacken der ZIP-Datei
echo "Unzipping archive..."
unzip /data/cephfs-1/work/groups/mittermaier/stimmaufnahmen/$(date +%Y-%m-%d)/Export.zip -d /data/cephfs-1/work/groups/mittermaier/stimmaufnahmen/$(date +%Y-%m-%d)

# Step 2: Set permissions for the moved files
echo "Setting permissions for files in $TARGET_DIR..."
chmod -R 755 "$TARGET_DIR"

# Step 3: Convert .aac files to .wav and replace them in place
echo "Converting .aac/.m4a files to .wav..."
find "$TARGET_DIR" -type f \( -name '*.aac' -o -name '*.m4a' \) | while read -r file; do
    wav_file="${file%.*}.wav"
    attempt=1
    max_attempts=3
    success=0
    while [ $attempt -le $max_attempts ]; do
        echo "Processing $file (Attempt $attempt)..."
        if ffmpeg -y -i "$file" "$wav_file"; then
            # Check that the output file is not empty
            if [ -s "$wav_file" ]; then
                echo "Conversion successful: $wav_file"
                rm "$file"
                success=1
                break
            else
                echo "Conversion produced an empty file: $wav_file" >&2
            fi
        else
            echo "Error converting $file on attempt $attempt" >&2
        fi
        attempt=$((attempt+1))
        sleep 1  # optional delay before retrying
    done
    if [ $success -ne 1 ]; then
        echo "Failed to convert $file after $max_attempts attempts." >&2
    fi
done

# Step 4: Rename "gedicht" to "poem" in filenames
echo "Renaming 'gedicht' to 'poem' in filenames..."
find "$TARGET_DIR" -depth -name "*gedicht*" -exec bash -c '
for oldpath do
    newpath="${oldpath//gedicht/poem}"
    mv -v "$oldpath" "$newpath"
done
' _ {} +

# (Optional) Step 5: Run your Python scripts (metadata extraction, config building, etc.)
cd /data/cephfs-1/home/users/joli13_c/voice_biomarker
uv run src/utils/extract_metadata.py -d "$TARGET_DIR"

# Step 6: Update paths in config files (config.yml and config_debug.yml)

CONFIG_FILES=(
  "/data/cephfs-1/home/users/joli13_c/voice_biomarker/config.yml"
  "/data/cephfs-1/home/users/joli13_c/voice_biomarker/config_debug.yml"
)

cd /data/cephfs-1/work/groups/mittermaier/stimmaufnahmen || exit 1
latest_dates=($(ls -d 202* | sort -r | head -n 2))

NEW_DATE="${latest_dates[0]}"
OLD_DATE="${latest_dates[1]}"

for file in "${CONFIG_FILES[@]}"; do
  echo "Updating $file from $OLD_DATE to $NEW_DATE..."
  sed -i \
    -e "s|stimmaufnahmen/$OLD_DATE|stimmaufnahmen/$NEW_DATE|g" \
    -e "s|wav2vec2_$OLD_DATE|wav2vec2_$NEW_DATE|g" \
    -e "s|parselmouth_$OLD_DATE|parselmouth_$NEW_DATE|g" \
    "$file"
done

echo "Config files updated."

uv_slurm 16G 16 src/features/parselmouth_extractor.py
uv_slurm 32G 16 src/features/get_embeddings.py

echo "Done!"
