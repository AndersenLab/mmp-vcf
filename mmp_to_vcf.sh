curl http://genome.sfu.ca/mmp/mmp_mut_strains_data_Mar14.txt > mmp_mutations.txt

# Generate strain list
cut -f 3 mmp_mutations.txt  | sort | uniq | grep -v 'strain' > mmp_strains.txt

# Split out variants into strain
while read p; do
  cat <(cat vcf_header.txt | awk -v p=${p} '{ print gensub("__SAMPLE__",p, $0); }')  <(grep $p mmp_mutations.txt | cut -f 2,3,4,5,6,7,8,9 | awk '{ print $3 "\t" $4 "\t" $1 "\t" $5 "\t" $6 "\t.\t.\t.\tGT\t1/1"}' | sort -k1,1 -k2,2n) | \
  bcftools view  -O z  > strain_variants/$p.vcf.gz
  bcftools index -f strain_variants/$p.vcf.gz
done < mmp_strains.txt