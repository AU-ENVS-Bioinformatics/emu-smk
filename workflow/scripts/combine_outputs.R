# Get list of files from command line
library(dplyr)
library(tidyr)
run <- function(infiles, outfile, ranks){
    # Read all TSV files into dataframes and combine them
    samples_names <- gsub(".tsv", "", basename(infiles))
    process_file <- function(infile) {
        sample_name <- gsub(".tsv", "", basename(infile))
        df <- infile %>%
            read.table(, header = TRUE, sep = "\t", stringsAsFactors = FALSE) %>% 
            select(-abundance)
        # Replace estimated.counts with sample name
        colnames(df)[grep("estimated.counts", colnames(df))] <- sample_name
        df
    }
    dfs <- lapply(infiles, process_file)


    #  Combine all dataframes into one using left_join with all columns that are not samples_names as keys
    taxa_cols <- setdiff(colnames(dfs[[1]]), samples_names)
    combined_df <- Reduce(\(x, y) dplyr::full_join(x, y, by = taxa_cols), dfs) %>%
        mutate(across(all_of(taxa_cols), as.character)) %>%
        mutate(across(all_of(taxa_cols), ~na_if(., "")))
    # Replace NA with 0 for every column in samples_names
    replace_na <- function(x) {
        x[is.na(x)] <- 0
        x
    }
    combined_df[samples_names] <- lapply(combined_df[samples_names], replace_na)

    combined_df <- combined_df %>%
        group_by(across(all_of(taxa_cols))) %>%
        summarise(across(all_of(samples_names), \(x) sum(x, na.rm = TRUE))) %>%
        ungroup()

    rownames(combined_df) <- make.unique(rownames(combined_df))


    # If lineage column is present, split it into multiple columns
    if ("lineage" %in% colnames(combined_df)) {
        combined_df <- combined_df %>%
            separate(lineage, into = ranks, sep = ";", fill = "right", remove = TRUE, extra = "merge")
    }

    # Write combined dataframe to file
    write.table(combined_df, outfile, sep = "\t", row.names = FALSE)
}

run(
  as.character(snakemake@input), 
  snakemake@output[[1]],
  ranks = snakemake@params$ranks
)