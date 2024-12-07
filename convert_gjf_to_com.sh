#!/bin/bash
# Loop through all .gjf files in the current directory
for gjf_file in Cl3PNPCl3.gjf; do
    # Extract the base name (without extension) of the .gjf file
    base_name=$(basename "$gjf_file" .gjf)

    # Create the output .com file (same name as the .gjf file)
    output_file="$base_name"_optfreq_pcmtol.com

    # Update the %chk=filename line in template.txt to use base_name
    # Replace the %chk=filename line with %chk=base_name
    sed "s|%chk=filename|%chk=${base_name}_optfreq_pcmtol|" template.txt > "$output_file"

    # Extract coordinates from the gjf file, excluding any connectivity information
    coordinates=$(sed -n '/0 1/,/^\s*$/p' "$gjf_file") 

    # Check if coordinates are found
    if [ -z "$coordinates" ]; then
        echo "No coordinates found in $gjf_file"
        continue
    fi

    # Append the coordinates to the .com file with an extra empty line after
    echo "$coordinates" >> "$output_file"
    echo "" >> "$output_file"  # Add an empty line after the coordinates

    echo "Coordinates from $gjf_file saved to $output_file"
done

echo "Processing complete."


