library(phyloseq)

run <- function(data, metadata_file, out_phyloseq, out_counts, out_taxonomy) {
  # Read tsv
  data <- read.table(data, header=TRUE, row.names=1, sep="\t")
  metadata <- read.csv(metadata_file, row.names=1)

  # Arrange data
  stopifnot(all(rownames(metadata) %in% colnames(data)))
  abundance <- data[,rownames(metadata)]
  taxonomy <- data[, !(colnames(data) %in% rownames(metadata))]
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
  saveRDS(physeq, out_phyloseq)
  abundance <- cbind("OTU"=rownames(abundance), abundance)
  write.csv(abundance, out_counts, row.names=FALSE)
  taxonomy <- cbind("OTU"=rownames(taxonomy), taxonomy)
  write.csv(taxonomy, out_taxonomy, row.names=FALSE)
}

run(
  snakemake@input$otu, 
  snakemake@input$metadata, 
  snakemake@output$phyloseq[[1]],
  snakemake@output$counts[[1]],
  snakemake@output$taxonomy[[1]]
)