method=MP2
basis=augccpVTZ
solvent=pcmchloro
jobpref=optfreq

ref=("HCl")
gen=("Cl3PNH" "Me3SiCl" "Cl3PNSiMe3")

for i in "${gen[@]}"; do

cp "$ref"_"$jobpref"_"$solvent"_"$method"_"$basis".com "$i"_"$jobpref"_"$solvent"_"$method"_"$basis".com
sed -i s/$ref/$i/g "$i"_"$jobpref"_"$solvent"_"$method"_"$basis".com

done

