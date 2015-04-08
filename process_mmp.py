from subprocess import PIPE, Popen


c = 0

reference = "/Users/dancook/Documents/git/pyPipeline/genomes/WS245/c_elegans.PRJNA13758.WS245.genomic.fa.gz"

def fetch_sequence(chrom, start, end, reference):
	pos =  "{chrom}:{start}-{end}".format(**locals())
	out, err = Popen(["samtools", "faidx", reference, pos], stdout=PIPE, stderr=PIPE).communicate()
	if err == "":
		return ''.join(out.strip().split("\n")[1:])
	else:
		raise Exception(err)


print fetch_sequence("II",1,100, reference)


cur_pos = 0

with open("mmp_mutations.txt", "r") as f:
	for i in f.xreadlines():
		c += 1 
		i = i.strip("\n").split("\t")
		if c < 10000000:
			if i[4] != cur_pos:
				cur_pos = i[4]
				if i[10].find("deletion") >= 0:
					print i