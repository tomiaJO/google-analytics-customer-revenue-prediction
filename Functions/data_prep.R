replaceJSONColumns <- function(dt, json_columns){
  extracted_json_columns <- map(json_columns, ~{
    message(glue("extrating colum: {.x}..."))
    extractJSONColumn(dt, .x)
  })
  
  names(extracted_json_columns) <- json_columns
  
  extracted_json_columns <- reduce(extracted_json_columns, cbind)
  
  dt_with_json_columns <- reduce(list(dt, extracted_json_columns), cbind)
  dt_with_json_columns[, (json_columns) := NULL]
}

extractJSONColumn <- function(dt, column_name) {
  dt_json_columns <- sprintf('[%s]', paste(dt[[column_name]], collapse = ',')) %>%
    jsonlite::fromJSON(flatten = T) %>% 
    as.data.table()
  
  setnames(dt_json_columns, paste0(column_name, ".", names(dt_json_columns)))
}

keepOnlyColumnsWithMoreThanOneLevel_ <- function(dt) {
  
  columns_names <- names(dt)
  bool_column_has_only_one_level <- map(columns_names, ~{dt[, uniqueN(get(.x))] == 1}) %>% unlist()
  columns_with_only_one_level <- columns_names[bool_column_has_only_one_level]
  
  dt[, (columns_with_only_one_level) := NULL]
}

fixEncodingForNAs_ <- function(dt) {
  walk(names(dt),~{
    dt[get(.x) %in% c("(not set)","not available in demo dataset", "(not provided)"),
          (.x) := NA]
  })
}

fixColumnFormattings_ <- function(dt) {
  dt[, `:=`(visitStartTime = as.POSIXct(visitStartTime, tz = "UTC", origin = '1970-01-01'),
            fullVisitorId  = as.factor(as.character(fullVisitorId)),
            visitId        = as.factor(as.character(visitId))
  )]
  
  totals_columns <- names(dt)[grepl(pattern = "totals.", x = names(dt))]
  walk(totals_columns, ~{
    dt[, (.x) := as.numeric(get(.x))]
    dt[is.na(get(.x)), (.x) := 0]
  })
  
  chr_columns <- names(dt)[dt[, sapply(.SD, is.character)]]
  walk(chr_columns, ~{
    dt[, (.x) := as.factor(get(.x))]
  })
  
}