# Get list of files from command line
library(dplyr)
run <- function(infiles, outfile){
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
    combined_df <- Reduce(\(x, y) dplyr::full_join(x, y, by = taxa_cols), dfs)
    # Replace NA with 0 for every column in samples_names
    replace_na <- function(x) {
        x[is.na(x)] <- 0
        x
    }
    combined_df[samples_names] <- lapply(combined_df[samples_names], replace_na)
    # Write combined dataframe to file
    write.table(combined_df, outfile, sep = "\t", row.names = FALSE)
}

run(
  as.character(snakemake@input), 
  snakemake@output[[1]]
)