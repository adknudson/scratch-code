from gtfparse import read_gtf

df = read_gtf("data/Homo_sapiens.GRCh38.101.gtf")
df2 = df[df["feature"] == "gene"]
df3 = df2[['gene_id', 'gene_name', 'gene_biotype']]

df3.to_csv("data/Homo_sapiens_genes.csv", index=False)