#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)
library(lubridate)
library(hms)
library(readr)
library(tidyr)

# ---- UI ----
ui <- fluidPage(
  titlePanel("PAMS Data Tidying App"),
  
  sidebarLayout(
    sidebarPanel(
      
      h4("Step 1: Upload File"),
      fileInput("file", "Upload PAMS Result Set CSV",
                accept = ".csv",
                buttonLabel = "Browse...",
                placeholder = "No file selected"),
      
      hr(),
      
      h4("Step 2: Options"),
      checkboxInput("drift",
                    "Apply Timestamp Drift Correction",
                    value = FALSE),
      helpText("Check this if timestamps drifted past the hour"),
      
      hr(),
      
      h4("Step 3: Download"),
      downloadButton("download", "Download Completed CSV"),
      
      br(),br(),
      
      # success message appears once data is tidied
      uiOutput("status")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Raw Data Preview",
                 br(),
                 tableOutput("raw_preview")),
        tabPanel("Tidied Data Preview",
                 br(),
                 tableOutput("tidy_preview")),
        tabPanel("Summary",
                 br(),
                 verbatimTextOutput("summary"))
      )
    )
  )
)

# ---- Server ----
server <- function(input, output, session) {
  
  # --- Reactive: Read the uploaded file ---
  raw_data <- reactive({
    req(input$file)
    
    tryCatch({
      read_csv(input$file$datapath, skip = 4) %>%
        select(-...1, -...2, -...8)
    }, error = function(e) {
      showNotification(paste("Error reading file:", e$message), type = "error")
      NULL
    })
  })
  
  # --- Reactive: Data tidying code ---
  tidy_data <- reactive({
    req(raw_data())
    
    tryCatch({
      df <- raw_data()
      
      # Add the missing column names
      colnames(df)[1] <- "File Name"
      colnames(df)[2] <- "Date"
      colnames(df)[3] <- "Time"
      colnames(df)[4] <- "Hour"
      colnames(df)[5] <- "PAMSHC"
      colnames(df)[6] <- "Total Unknown"
      colnames(df)[7] <- "TNMOC"
      
      df <- df %>%
        mutate(date = dmy(Date),
               hour = as.numeric(Hour)) %>%
        select(-Date, -Hour)
      
      # Optional: timestamp drift correction
      if (input$drift) {
        df <- df %>%
          mutate(minutes = minute(Time))
        
        df$hour[df$minutes >= 0 & df$minutes < 20] <-
          df$hour[df$minutes >= 0 & df$minutes < 20] - 1
        df$date[df$hour == -1] <- df$date[df$hour == -1] - 1
        df$hour <- replace(df$hour, df$hour == -1, 23)
        
        df <- df %>% select(-minutes)
      }
      
      # Create datetime column
      df <- df %>%
        mutate(
          newHour  = as_hms(hour * 3600),
          datetime = as.POSIXct(as_datetime(paste(date, newHour))) - (1 * 60 * 60)
        )
      
      # Drop empty rows at the bottom
      df <- df %>% drop_na()
      
      # Round summary columns to 2 decimal places
      df$PAMSHC          <- round(df$PAMSHC, 2)
      df$`Total Unknown` <- round(df$`Total Unknown`, 2)
      df$TNMOC           <- round(df$TNMOC, 2)
      
      # Add Null/Qualifying Codes column
      df[, "Null/Qualifying Codes"] <- NA
      
      # Reorder columns
      df <- df[, c(
        "datetime","Null/Qualifying Codes","File Name",
        "Ethane","Ethylene","Propane","Propylene","Isobutane","n-Butane",
        "Acetylene","t-2-Butene","1-Butene","c-2-Butene","Cyclopentane",
        "Isopentane","Pentane","1,3-Butadiene","t-2-Pentene","1-Pentene",
        "c-2-Pentene","2,2-Dimethylbutane","2,3-Dimethylbutane","2-Methylpentane",
        "3-Methylpentane","Hexane","Isoprene","Hexene","Methylcyclopentane",
        "2,4-Dimethylpentane","Benzene","Cyclohexane","2-Methylhexane",
        "2,3-Dimethylpentane","3-Methylhexane","2,2,4-Trimethylpentane",
        "n-heptane","Methylcyclohexane","2,3,4-Trimethylpentane","Toluene",
        "2-Methylheptane","3-Methylheptane","n-Octane","Ethylbenzene",
        "MP-Xylene","Styrene","o-Xylene","n-Nonane","Isopropylbenzene",
        "alpha-pinene","n-propylbenzene","m-Ethyltoluene","p-Ethyltolune",
        "1,3,5-Trimethylbenzene","o-Ethyltoluene","beta-pinene",
        "1,2,4-Trimethylbenzene","Decane","1,2,3-Trimethylbenzene",
        "1,3-Diethylbenzene","1,4-Diethylbenzene","Undecane","n-Dodecane",
        "PAMSHC","Total Unknown","TNMOC"
      )]
      
      # Fill missing hours with NA
      df <- df %>%
        complete(datetime = seq(from = first(datetime),
                                to   = last(datetime),
                                by   = "hours"))
     
       # fix format to display datetime in preview
      # df <- df %>%
      #   format(as.character(datetime)) --> not sure if this works yet
      
      # Add AQS codes row at the top
      df <- df %>%
        add_row(
          "datetime"=NA,"Null/Qualifying Codes"=NA,"File Name"=NA,
          "Ethane"=43202,"Ethylene"=43203,"Propane"=43204,"Propylene"=43205,
          "Isobutane"=43214,"n-Butane"=43212,"Acetylene"=43206,
          "t-2-Butene"=43216,"1-Butene"=43280,"c-2-Butene"=43217,
          "Cyclopentane"=43242,"Isopentane"=43221,"Pentane"=43220,
          "1,3-Butadiene"=43218,"t-2-Pentene"=43226,"1-Pentene"=43224,
          "c-2-Pentene"=43227,"2,2-Dimethylbutane"=43244,"2,3-Dimethylbutane"=43284,
          "2-Methylpentane"=43285,"3-Methylpentane"=43230,"Hexane"=43231,
          "Isoprene"=43243,"Hexene"=43245,"Methylcyclopentane"=43262,
          "2,4-Dimethylpentane"=43247,"Benzene"=45201,"Cyclohexane"=43248,
          "2-Methylhexane"=43236,"2,3-Dimethylpentane"=43291,"3-Methylhexane"=43249,
          "2,2,4-Trimethylpentane"=43250,"n-heptane"=43232,"Methylcyclohexane"=43261,
          "2,3,4-Trimethylpentane"=43252,"Toluene"=45202,"2-Methylheptane"=43960,
          "3-Methylheptane"=43253,"n-Octane"=45233,"Ethylbenzene"=45203,
          "MP-Xylene"=45109,"Styrene"=45220,"o-Xylene"=45204,"n-Nonane"=43235,
          "Isopropylbenzene"=45210,"alpha-pinene"=43256,"n-propylbenzene"=45209,
          "m-Ethyltoluene"=45212,"p-Ethyltolune"=45213,
          "1,3,5-Trimethylbenzene"=45207,"o-Ethyltoluene"=45211,
          "beta-pinene"=43257,"1,2,4-Trimethylbenzene"=45208,"Decane"=43238,
          "1,2,3-Trimethylbenzene"=45225,"1,3-Diethylbenzene"=45218,
          "1,4-Diethylbenzene"=45219,"Undecane"=43954,"n-Dodecane"=43141,
          "PAMSHC"=43000,"Total Unknown"=49999,"TNMOC"=43102,
          .before = 1
        )
      
      return(df)
      
    }, error = function(e) {
      showNotification(paste("Error tidying data:", e$message), type = "error")
      NULL
    })
  })
  
  # --- Raw data preview (first 10 rows) ---
  output$raw_preview <- renderTable({
    req(raw_data())
    head(raw_data(), 10)
  })
  
  # --- Tidied data preview (first 10 rows, skipping AQS codes row) ---
  output$tidy_preview <- renderTable({
    req(tidy_data())
    head(tidy_data(), 10)
  })
  
  # --- Summary tab ---
  output$summary <- renderPrint({
    req(tidy_data())
    df <- tidy_data()
    cat("Total rows (including AQS codes row):", nrow(df), "\n")
    cat("Total columns:", ncol(df), "\n")
    cat("Date range:", 
        format(min(df$datetime, na.rm = TRUE)), "to",
        format(max(df$datetime, na.rm = TRUE)), "\n")
    cat("Missing hours filled with NA: YES\n")
    cat("Timestamp drift correction applied:", input$drift, "\n")
  })
  
  # --- Green success message after tidying ---
  output$status <- renderUI({
    req(tidy_data())
    tags$p("Data tidied successfully!",
           style = "color: green; font-weight: bold;")
  })
  
  # --- Download handler ---
  # Automatically names output file to match input (e.g. "Aug 28-31 2025 result set.csv"
  # becomes "Aug 28-31 2025 complete.csv")
  output$download <- downloadHandler(
    filename = function() {
      if (!is.null(input$file)) {
        gsub("result set", "complete", input$file$name, ignore.case = TRUE)
      } else {
        paste0("PAMS_complete_", Sys.Date(), ".csv")
      }
    },
    content = function(file) {
      req(tidy_data())
      write.csv(tidy_data(), file, row.names = FALSE)
    }
  )
}

shinyApp(ui, server)