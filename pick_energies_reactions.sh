#!/bin/bash
method=MP2
basis=augccpVTZ
solvent=pcmchloro
jobpref=optfreq

# Define reactants and products
reactants=("HCl" "Cl3PNSiMe3")
products=("Cl3PNH" "Me3SiCl")

# Initialize arrays to store results
results=()
differences=()

# Merge reactants and products into a single list of unique compounds
all_compounds=("${reactants[@]}" "${products[@]}")

# Remove duplicates if any
unique_compounds=($(printf "%s\n" "${all_compounds[@]}" | sort -u))

# Conversion factor from Hartree to kcal/mol
hartree_to_kcal=627.509

# Function to extract energies for a compound
extract_energies() {
    local compound="$1"
    local Ee=$(grep "SCF Do" "${compound}_"$jobpref"_"$solvent"_"$method"_"$basis".log" | tail -1 | awk '{print $5}')
    local E0=$(grep "Sum of electronic and zero-point Energies" "${compound}_"$jobpref"_"$solvent"_"$method"_"$basis".log" | awk '{print $NF}')
    local DU=$(grep "Sum of electronic and thermal Energies" "${compound}_"$jobpref"_"$solvent"_"$method"_"$basis".log" | awk '{print $NF}')
    local DH=$(grep "Sum of electronic and thermal Enthalpies" "${compound}_"$jobpref"_"$solvent"_"$method"_"$basis".log" | awk '{print $NF}')
    local DG=$(grep "Sum of electronic and thermal Free Energies" "${compound}_"$jobpref"_"$solvent"_"$method"_"$basis".log" | awk '{print $NF}')
    echo "$Ee,$E0,$DU,$DH,$DG"
}

# Extract and store energies for all compounds
declare -A energy_map
for compound in "${unique_compounds[@]}"; do
    energies=$(extract_energies "$compound")
    energy_map["$compound"]="$energies"
    results+=("$compound,$energies")
done

# Compute energy differences: products - reactants
sum_products=(0 0 0 0 0)
sum_reactants=(0 0 0 0 0)

# Sum energies for products
for compound in "${products[@]}"; do
    IFS=',' read -r -a energies <<< "${energy_map[$compound]}"
    for i in {0..4}; do
        sum_products[$i]=$(echo "${sum_products[$i]} + ${energies[$i]}" | bc)
    done
done

# Sum energies for reactants
for compound in "${reactants[@]}"; do
    IFS=',' read -r -a energies <<< "${energy_map[$compound]}"
    for i in {0..4}; do
        sum_reactants[$i]=$(echo "${sum_reactants[$i]} + ${energies[$i]}" | bc)
    done
done

# Calculate differences
diff_hartree=()
diffs=()
for i in {0..4}; do
    diff_hartree[$i]=$(echo "${sum_products[$i]} - ${sum_reactants[$i]}" | bc)
    diffs[$i]=$(echo "${diff_hartree[$i]} * $hartree_to_kcal" | bc)
done
differences=("Diff,${diffs[*]}")

# Print the results
#echo -e "Lig,Ee,E0,DU,DH,DG"
#for row in "${results[@]}"; do
#    echo "$row"
#done

# Generate dynamic labels
products_label=$(IFS='+'; echo "${products[*]}")
reactants_label=$(IFS='+'; echo "${reactants[*]}")

echo "$method, $basis,$solvent,${reactants_label} --> ${products_label},$(IFS=','; echo "${diffs[*]}")"

