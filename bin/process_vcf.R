#!/usr/bin/env Rscript
library(vcfR)

args <- commandArgs(trailingOnly = TRUE)
vcf_file <- args[1]

vcf <- vcfR::read.vcfR(vcf_file)
chrom <- vcfR::create.chromR(name='', vcf=vcf)
chrom <- vcfR::proc.chromR(chrom)

png("vcf_base_stats.png")
vcr_base_plot <- vcfR::plot(chrom)
dev.off()