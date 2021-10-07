scone fspf create /fspf/volume.fspf
scone fspf addr /fspf/volume.fspf / --not-protected --kernel /
scone fspf addr /fspf/volume.fspf /app --encrypted --kernel /app
scone fspf addf /fspf/volume.fspf /app /native-files /app
scone fspf encrypt /fspf/volume.fspf > /native-files/keytag
