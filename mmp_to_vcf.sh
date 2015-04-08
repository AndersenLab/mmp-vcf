curl http://genome.sfu.ca/mmp/mmp_mut_strains_data_Mar14.txt > mmp_mutations.txt

# Generate strain list

if [ ! -e "mmp_strains.txt" ]; then
  cut -f 3 mmp_mutations.txt  | sort | uniq | grep -v 'strain' > mmp_strains.txt
fi

# Split out variants into strain.
while read p; do
  cat <(cat vcf_header.txt | awk -v p=${p} '{ print gensub("__SAMPLE__",p, $0); }')  <(grep $p mmp_mutations.txt | cut -f 2-15 | awk ' $10 == "complex_change" { $5="N"; $6="<CNV>"} $10 == "deletion" { $5="N"; $6="<DEL>"; } $10 == "insertion" { $5=N; $6="<INS>"; } { print $3 "\t" $4 "\t" $1 "\t" $5 "\t" $6 "\t.\t.\t.\tGT\t1/1"}' | sort -k1,1 -k2,2n)
  #bcftools view  -O z  > strain_variants/$p.vcf.gz
  #bcftools index -f strain_variants/$p.vcf.gz
done < mmp_strains.txt

# Merge mutational strains together.
bcftools merge  --merge snps `ls strain_variants/*.vcf.gz`  | awk ' {gsub("\\./\\.","0/0",$0); print $0 }' | bcftools view -O z > mmp_ems.vcf.gz