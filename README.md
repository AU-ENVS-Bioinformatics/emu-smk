# Snakemake workflow: EMU-smk

[![Snakemake](https://img.shields.io/badge/snakemake-≥6.3.0-brightgreen.svg)](https://snakemake.github.io)
[![GitHub actions status](https://github.com/AU-ENVS-Bioinformatics/emu-smk/workflows/Tests/badge.svg?branch=main)](https://github.com/AU-ENVS-Bioinformatics/emu-smk/actions?query=branch%3Amain+workflow%3ATests)


A Snakemake workflow for running [EMU](https://gitlab.com/treangenlab/emu). 


## Usage

First, prepare a metadata csv file. You can use this as an [example](metadata.csv). At least, it should have one column that will be used as the identifier of every sample. It must match with the name of the file without the extension. 

Then, edit the [configuration file](config/config.yaml) so it fits your case. At least, you should indicate (a) the file extension (by default .fastq), (b) the directory where those files are located, (c) the filepath of the metadata CSV  and (d) the filepath of the directory with the EMU database. This repository contains toy examples to ensure the pipeline works, but you want to replace them. 

```bash
snakemake --use-conda -n
snakemake --use-conda -c100
```

## Output

The pipeline produces two TSV files containing the abundances and taxonomy and one RDS file with a phyloseq object with the counts, taxa and metadata (from any additional column you add in the metadata CSV) that you can read into Rstudio to start analyzing your data. These files will be produces in the "results" directory.  

Optionally, you can keep additional files per sample (such as the alignments and a fasta of every unclassified sequences using the command "--notemp" that, unintuitively, means keep all temporary files). Those files will be located in the "steps" directory. 

```bash
snakemake --use-conda -n --notemp
snakemake --use-conda -c100 --notemp
```