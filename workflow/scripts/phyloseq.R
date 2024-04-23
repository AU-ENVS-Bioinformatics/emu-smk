library(phyloseq)

run <- function(abundance_file, taxonomy_file, metadata_file, output_file) {
  # Read tsv
  abundance <- read.table(abundance_file, header=TRUE, row.names=1, sep="\t")
  taxonomy <- read.table(taxonomy_file, header=TRUE, row.names=1, sep="\t")
  metadata <- read.csv(metadata_file, row.names=1)

  # Arrange data
  abundance <- abundance[rownames(taxonomy),rownames(metadata)]
  taxonomy <- taxonomy[,rev(colnames(taxonomy))]

  # Make assertions
  stopifnot(all(rownames(abundance) == rownames(taxonomy)))
  stopifnot(all(colnames(abundance) == rownames(metadata)))

  # Create phyloseq object
  physeq <- phyloseq(otu_table(abundance, taxa_are_rows=TRUE),
                     tax_table(as.matrix(taxonomy)),
                     sample_data(metadata))

  # Save phyloseq object
  saveRDS(physeq, output_file)
}

run(
  snakemake@input$abundances, 
  snakemake@input$taxonomy,
  snakemake@input$metadata, 
  snakemake@output[[1]]
)