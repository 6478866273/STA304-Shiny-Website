library(shiny)
library(plotly)

# ------------------------------------------------------------
# 1. Load data
# ------------------------------------------------------------

df <- read.csv("STA304_Website_Data.csv")

# Average weekly gaming hours
df$weekly_gaming_hours <-
  df$gaming_hours_per_day * df$gaming_days / 2


# ------------------------------------------------------------
# 2. User Interface
# ------------------------------------------------------------


variable_labels <- c("Weekly gaming hours"="weekly_gaming_hours", "Gaming days (14 days)"="gaming_days", "Bedtime gaming days"="bedtime_gaming_days", "Nightly sleep hours"="sleep_hours_per_night", "Sleep quality"="sleep_quality", "Sleep latency (minutes)"="sleep_latency", "Caffeine servings"="caffeine_servings", "Non-gaming screen time"="non_gaming_screen_time")

ui <- navbarPage(
  
  title = "Gaming Habits and Sleep",
  
  # ----------------------------------------------------------
  # Custom appearance
  # ----------------------------------------------------------
  
  header = tags$head(
    tags$style(HTML("

      body {background-color: #F7FBFF;}

      .navbar {
  background-color: #DCEEFF !important;
  border: none !important;
  min-height: 0 !important;
}

.navbar-header {
  width: 100% !important;
  float: none !important;
  background-color: #DCEEFF !important;
}

.navbar-default .navbar-brand {
  float: none !important;
  display: block !important;
  height: auto !important;
  padding: 18px 20px !important;
  color: #234C7A !important;
  font-size: 26px !important;
  font-weight: 700 !important;}

.navbar-collapse {
  clear: both !important;
  background-color: #B8D5F0 !important;
  padding-left: 20px !important;}

.navbar-nav {float: none !important; margin: 0 !important;}

.navbar-nav > li {float: left !important;}

.navbar-default .navbar-nav > li > a {
  color: #183B63 !important;
  font-size: 17px !important;
  font-weight: 600 !important;
  padding: 14px 22px !important;}

.navbar-default .navbar-nav > li > a:hover {
  background-color: #A7CAE9 !important;
  color: #102F50 !important;}

.navbar-default .navbar-nav > .active > a,
.navbar-default .navbar-nav > .active > a:hover,
.navbar-default .navbar-nav > .active > a:focus {
  background-color: #FFFFFF !important;
  color: #163A63 !important;
  font-weight: 700 !important;
  border-bottom: 4px solid #70A9E0 !important;}

      .well {background-color: #F0F7FD; border-color: #C9DFF2;}

      h1, h2, h3, h4 {color: #234C7A;}

      .about-box {
        background-color: white;
        border: 1px solid #D9E7F3; border-radius: 8px;
        padding: 20px;
        margin-bottom: 20px;}

            pre {white-space: pre-wrap !important; word-wrap: break-word !important;
           overflow-x: hidden !important;}
    
")),
    
    tags$script(HTML("
      $(document).on('shiny:connected', function() {

        function bindLiveAxis(sliderId, axisName, minValue) {
          var attempts = 0;

          function attachSlider() {
            var slider = $('#' + sliderId).data('ionRangeSlider');

            if (!slider) {
              attempts++;
              if (attempts < 30) {
                setTimeout(attachSlider, 100);
              }
              return;
            }

            slider.update({
              onChange: function(data) {
                var plot = document.getElementById('selected_plot');

                if (!plot || !plot.data) {
                  return;
                }

                var update = {};
                update[axisName + '.range'] = [minValue, data.from];

                Plotly.relayout(plot, update);
              }
            });
          }

          attachSlider();
        }

        bindLiveAxis('gaming_x_max', 'xaxis', 0);
        bindLiveAxis('sleep_y_max', 'yaxis', 0);

        bindLiveAxis('bedtime_x_max', 'xaxis', 0);
        bindLiveAxis('quality_y_max', 'yaxis', 1);

        bindLiveAxis('latency_x_max', 'xaxis', 0);
        bindLiveAxis('latency_y_max', 'yaxis', 0);

      });
    "))
  ),
  
  
  # ==========================================================
  # TAB 1: EXPLORE
  # ==========================================================
  
  tabPanel(
    
    "Explore",
    
    fluidPage(
      
      br(),
      
      h2("Gaming Habits and Sleep"),
      
      h4("STA304 Group Project | Sampling Error 505"),
      
      p("Explore gaming habits and sleep among Fall 2026 STA304H5 students."),
      
      br(),
      
      sidebarLayout(
        
        # ------------------------------------------------------
        # Sidebar
        # ------------------------------------------------------
        
        sidebarPanel(
          
          h3("Customize the Plots"),
          
          selectInput(
            "gaming_filter",
            "Filter by gaming status:",
            choices = c(
              "All Respondents" = "all",
              "Gamers" = "gamers",
              "Non-gamers" = "non_gamers"),
            selected = "all"),
          
          selectInput(
            "plot_choice",
            "Choose a graph:",
            choices = c(
              "Gaming Time vs. Sleep Duration" = "plot1",
              "Bedtime Gaming vs. Sleep Quality" = "plot2",
              "Gaming Time vs. Sleep Latency" = "plot3"),
            selected = "plot1"),
          
          selectInput(
            "point_color",
            "Choose a colour:",
            choices = c(
              "Light Blue" = "#70A9E0",
              "Dark Blue" = "#245C9F",
              "Purple" = "#9675C9",
              "Green" = "#57A68A"
            ),
            selected = "#70A9E0"
          ),
          
          hr(),
          
          h3("Adjust Axis Limits"),
          
          # Plot 1 controls
          conditionalPanel(
            
            condition = "input.plot_choice == 'plot1'",
            
            sliderInput(
              "gaming_x_max",
              "Maximum weekly gaming hours:",
              min = 10,
              max = 120,
              value = 120
            ),
            
            sliderInput("sleep_y_max", "Maximum sleep duration:",
                        min = 6, max = 12, value = 12)
          ),
          
          # Plot 2 controls
          conditionalPanel(
            
            condition = "input.plot_choice == 'plot2'",
            
            sliderInput(
              "bedtime_x_max", "Maximum bedtime gaming days:",
              min = 2, max = 14, value = 14),
            
            sliderInput(
              "quality_y_max", "Maximum sleep quality:",
              min = 5, max = 10, value = 10)
          ),
          
          # Plot 3 controls
          conditionalPanel(
            
            condition = "input.plot_choice == 'plot3'",
            
            sliderInput(
              "latency_x_max", "Maximum weekly gaming hours:",
              min = 10, max = 120, value = 120),
            
            sliderInput(
              "latency_y_max", "Maximum sleep latency:",
              min = 30, max = 240, value = 240)
          )
        ),
        
        
        # ------------------------------------------------------
        # Main panel
        # ------------------------------------------------------
        
        mainPanel(
          
          h2(textOutput("plot_title")),
          
          plotlyOutput("selected_plot", height = "470px"),
          
          conditionalPanel(
            condition = "input.plot_choice == 'plot2'",
            p("Sleep quality: 1 = Very poor; 10 = Very good.")
          ),
          
          p(
            "Axis controls change the displayed range only.",
            "Summary statistics and model results use all respondents",
            "in the selected subgroup."
          ),
          
          conditionalPanel(
            condition = "input.plot_choice == 'plot3'",
            p(
              "Each point represents one respondent.",
              "When shown, the regression line describes the unadjusted relationship,",
              "and the shaded band is a 95% confidence interval for the mean response.",
              "When regression can be estimated, the model results below additionally",
              "account for caffeine consumption and non-gaming screen time."
            )
          ),
          
          hr(),
          
          h3("Summary Statistics"),
          verbatimTextOutput("summary_stats"),
          
          h3("Statistical Analysis"),
          verbatimTextOutput("model_results"),
          
          h3("Interpretation"),
          p(textOutput("plot_description"))
          
        )
      )
    )
  ),
  
  
  # ==========================================================
  # TAB 2: ABOUT
  # ==========================================================
  
  tabPanel("Overview", fluidPage(
    h2("Research Dashboard"),
    p("Descriptive overview of the voluntary STA304H5 survey. Filters on this page apply to the overview only."),
    sidebarLayout(sidebarPanel(
      selectInput("ov_group", "Respondents", c("All"="all", "Gamers"="gamers", "Non-gamers"="non_gamers")),
      selectInput("ov_var", "Distribution variable", choices = variable_labels, selected="sleep_latency"),
      sliderInput("ov_caffeine", "Caffeine servings", 0, max(df$caffeine_servings), c(0,max(df$caffeine_servings))),
      sliderInput("ov_quality", "Sleep quality", 1,10,c(1,10))),
      mainPanel(uiOutput("ov_cards"), fluidRow(column(6,plotlyOutput("ov_hist")),column(6,plotlyOutput("ov_box"))),
        h3("Descriptive statistics"), tableOutput("ov_summary"),
        h3("Correlation matrix"), p("Pearson correlations; constant variables are left blank. Correlation does not establish causality."), plotlyOutput("ov_corr",height="500px")))
  )),
  tabPanel("Model Lab", fluidPage(
    h2("Regression and Model Comparison"),
    sidebarLayout(sidebarPanel(
      selectInput("lab_group", "Respondents", c("All"="all", "Gamers"="gamers", "Non-gamers"="non_gamers")),
      selectInput("lab_q", "Research question", c("RQ1: Sleep duration"="q1", "RQ2: Sleep quality"="q2", "RQ3: Sleep latency"="q3"), selected="q3"),
      conditionalPanel(condition = "input.lab_q == 'q3'",
        selectInput("lab_model", "Model specification", choices = c("Unadjusted" = "m1", "Caffeine adjusted" = "m2",
            "Screen time adjusted" = "m3", "Both adjusted" = "m4"), selected = "m4")), p("RQ1 and RQ2 use the original simple regression. Model selection applies to RQ3 only."),
      sliderInput("lab_ci", "Confidence level (%)", 90,99,95),
      numericInput("lab_x", "Gaming predictor for fitted mean (hours/week or days/14 days)", 10,min=0)),
      mainPanel(h3("Coefficient estimates and confidence intervals"), plotlyOutput("lab_coef",height="320px"),tableOutput("lab_table"),
        h3("Candidate model comparison"),tableOutput("lab_compare"),plotlyOutput("lab_aic",height="300px"),
        h3("Estimated mean response"), verbatimTextOutput("lab_pred"),
        p("Prediction fixes adjustment variables at subgroup medians. Intervals are model-based, not population-representative guarantees.")))
  )),
  tabPanel("Diagnostics", fluidPage(
    h2("Model Diagnostics and Sensitivity"),
    p("Uses the same subgroup and model specification selected in Model Lab."),
    fluidRow(column(6,plotlyOutput("diag_resid")),column(6,plotlyOutput("diag_qq"))),
    fluidRow(column(6,plotlyOutput("diag_cook")),column(6,plotlyOutput("diag_scale"))),
    h3("Sensitivity to influential observations"),
    p("Cook's distance above 4/n is a screening heuristic, not evidence of data error. The full-data model remains the primary result."),
    tableOutput("diag_sensitivity"),
    p("Model-based inference assumes an appropriate mean structure and independent, approximately homoskedastic errors; normality is relevant to small-sample inference. Voluntary sampling limits generalization."))) ,
  tabPanel(
    
    "About",
    
    fluidPage(
      
      br(),
      
      div(class = "about-box",
        
        h2("About This Study"),
        
        p("This project explores associations between video gaming habits
          and sleep among students enrolled in STA304H5 at the University
          of Toronto Mississauga during Fall 2026."),
        
        p("The cleaned dataset contains 88 survey responses.")
      ),
      
      
      div(class = "about-box",
        
        h3("Research Questions"),
        
        tags$ol(
          
          tags$li("Is average weekly video gaming time associated with
            average nightly sleep duration?"),
          
          tags$li("Is bedtime gaming frequency associated with
            self-reported sleep quality?"),
          
          tags$li(
            "After accounting for caffeine consumption and non-gaming
            electronic-device use before sleep, is average weekly
            gaming time associated with sleep-onset latency?")
        )
      ),
      
      
      div(class = "about-box",
        
        h3("Variables"),
        
        tags$ul(
          
          tags$li("Gaming hours per gaming day"),
          
          tags$li("Gaming days during the past two weeks"),
          
          tags$li("Bedtime gaming frequency"),
          
          tags$li("Average nightly sleep duration"),
          
          tags$li("Self-reported sleep quality"),
          
          tags$li("Sleep-onset latency"),
          
          tags$li("Caffeine consumption"),
          
          tags$li("Non-gaming screen time before sleep")
        )
      ),
      
      
      div(class = "about-box",
        
        h3("Sampling and Data Collection"),
        
        p("The survey was distributed to STA304H5 students through
          the course survey system. Participation was voluntary."),
        
        p("Responses were identified using anonymous course-specific
          codenames rather than student names or student numbers."),
        
        p("The approved questionnaire did not collect demographic variables.
          The interactive filter therefore uses gaming status to allow users
          to explore behavioural subgroups within the sample.")
        
      ),
      
      
      div(class = "about-box",
        
        h3("Important Limitations"),
        
        tags$ul(
          
          tags$li(
            "The sample was based on voluntary participation and is
            not a true probability sample."),
          
          tags$li(
            "Gaming and sleep measures were self-reported and may be
            affected by recall or reporting error."),
          
          tags$li(
            "The data are observational. Associations observed in
            this project should not be interpreted as causal effects."),
          
          tags$li(
            "A small number of unusual observations may influence
            fitted regression lines and summary statistics.")
        )
      ),
      
      
      div(class = "about-box",
        
        h3("Changes from the Original Analysis Plan"),
        
        p("The original proposal considered a chi-square test for the
    relationship between bedtime gaming and sleep quality.
    After feedback, this analysis was not used because both variables
    were quantitative and a chi-square test of independence was not
    appropriate."),
        
        p("Instead, regression-based analyses were used for the quantitative
    variables. For sleep-onset latency, multiple candidate regression
    models were compared using AIC.")
      ),
      
      div(class = "about-box",
        
        h3("Group"),
        
        p("Sampling Error 505"),
        
        p("STA304H5 — Fall 2026")
  ))))


# ------------------------------------------------------------
# 3. Server
# ------------------------------------------------------------

server <- function(input, output, session) {
  
  # ----------------------------------------------------------
  # Respondent filter
  # ----------------------------------------------------------
  
  filtered_df <- reactive({
    
    if (input$gaming_filter == "gamers") {
      
      df[df$gaming_days > 0, ]
      
    } else if (input$gaming_filter == "non_gamers") {
      
      df[df$gaming_days == 0, ]
      
    } else {df}
    
  })
  
  
  # ----------------------------------------------------------
  # Dynamic plot title
  # ----------------------------------------------------------
  
  output$plot_title <- renderText({
    
    if (input$plot_choice == "plot1") {
      
      "Weekly Gaming Time and Sleep Duration"
      
    } else if (input$plot_choice == "plot2") {
      
      "Bedtime Gaming Frequency and Sleep Quality"
      
    } else {
      
      "Weekly Gaming Time and Sleep-Onset Latency"
      
    }
    
  })
  
  
  # ----------------------------------------------------------
  # Interactive plots
  # ----------------------------------------------------------
  
  output$selected_plot <- renderPlotly({
    data_now <- filtered_df()
    
    if (input$plot_choice == "plot1") {
      fig <- plot_ly()
      
      if (length(unique(na.omit(data_now$weekly_gaming_hours))) >= 2) {
        model <- lm(sleep_hours_per_night ~ weekly_gaming_hours, data = data_now)
        x_grid <- seq(
          min(data_now$weekly_gaming_hours, na.rm = TRUE),
          max(data_now$weekly_gaming_hours, na.rm = TRUE),
          length.out = 100
        )
        pred <- predict(
          model,
          newdata = data.frame(weekly_gaming_hours = x_grid),
          interval = "confidence"
        )
        line_df <- data.frame(
          x = x_grid,
          fit = pred[, "fit"],
          lwr = pred[, "lwr"],
          upr = pred[, "upr"]
        )
        
        fig <- fig |>
          add_ribbons(
            data = line_df,
            x = ~x,
            ymin = ~lwr,
            ymax = ~upr,
            fillcolor = "rgba(35,76,122,0.15)",
            line = list(color = "rgba(0,0,0,0)"),
            hoverinfo = "skip",
            showlegend = FALSE
          ) |>
          add_lines(
            data = line_df,
            x = ~x,
            y = ~fit,
            line = list(color = "#234C7A", width = 2),
            hoverinfo = "skip",
            showlegend = FALSE
          )
      }
      
      fig <- fig |>
        add_markers(
          data = data_now,
          x = ~weekly_gaming_hours,
          y = ~sleep_hours_per_night,
          marker = list(
            color = input$point_color,
            size = 9,
            opacity = 0.65
          ),
          hovertemplate = paste(
            "Weekly gaming: %{x:.2f} hours",
            "<br>Sleep duration: %{y:.2f} hours",
            "<extra></extra>"
          ),
          showlegend = FALSE
        ) |>
        layout(
          title = list(text = "Gaming Time vs. Sleep Duration"),
          xaxis = list(
            title = "Average weekly gaming time (hours)",
            range = c(0, isolate(input$gaming_x_max))
          ),
          yaxis = list(
            title = "Average nightly sleep duration (hours)",
            range = c(0, isolate(input$sleep_y_max))
          ),
          transition = list(duration = 0)
        ) |>
        config(displayModeBar = FALSE, responsive = TRUE)
      
      fig
      
    } else if (input$plot_choice == "plot2") {
      fig <- plot_ly()
      
      if (length(unique(na.omit(data_now$bedtime_gaming_days))) >= 2) {
        model <- lm(sleep_quality ~ bedtime_gaming_days, data = data_now)
        x_grid <- seq(
          min(data_now$bedtime_gaming_days, na.rm = TRUE),
          max(data_now$bedtime_gaming_days, na.rm = TRUE),
          length.out = 100
        )
        pred <- predict(
          model,
          newdata = data.frame(bedtime_gaming_days = x_grid),
          interval = "confidence"
        )
        line_df <- data.frame(
          x = x_grid,
          fit = pred[, "fit"],
          lwr = pred[, "lwr"],
          upr = pred[, "upr"]
        )
        
        fig <- fig |>
          add_ribbons(
            data = line_df,
            x = ~x,
            ymin = ~lwr,
            ymax = ~upr,
            fillcolor = "rgba(35,76,122,0.15)",
            line = list(color = "rgba(0,0,0,0)"),
            hoverinfo = "skip",
            showlegend = FALSE
          ) |>
          add_lines(
            data = line_df,
            x = ~x,
            y = ~fit,
            line = list(color = "#234C7A", width = 2),
            hoverinfo = "skip",
            showlegend = FALSE
          )
      }
      
      fig <- fig |>
        add_markers(
          data = data_now,
          x = ~bedtime_gaming_days,
          y = ~sleep_quality,
          marker = list(
            color = input$point_color,
            size = 9,
            opacity = 0.55
          ),
          hovertemplate = paste(
            "Bedtime gaming: %{x:.0f} days",
            "<br>Sleep quality: %{y:.0f}",
            "<extra></extra>"
          ),
          showlegend = FALSE
        ) |>
        layout(
          title = list(text = "Bedtime Gaming vs. Sleep Quality"),
          xaxis = list(
            title = "Days gaming before sleep (past 14 days)",
            range = c(0, isolate(input$bedtime_x_max))
          ),
          yaxis = list(
            title = "Self-reported sleep quality (1-10)",
            range = c(1, isolate(input$quality_y_max))
          ),
          transition = list(duration = 0)
        ) |>
        config(displayModeBar = FALSE, responsive = TRUE)
      
      fig
      
    } else {
      fig <- plot_ly()
      
      if (length(unique(na.omit(data_now$weekly_gaming_hours))) >= 2) {
        model <- lm(sleep_latency ~ weekly_gaming_hours, data = data_now)
        x_grid <- seq(
          min(data_now$weekly_gaming_hours, na.rm = TRUE),
          max(data_now$weekly_gaming_hours, na.rm = TRUE),
          length.out = 100
        )
        pred <- predict(
          model,
          newdata = data.frame(weekly_gaming_hours = x_grid),
          interval = "confidence"
        )
        line_df <- data.frame(
          x = x_grid,
          fit = pred[, "fit"],
          lwr = pred[, "lwr"],
          upr = pred[, "upr"]
        )
        
        fig <- fig |>
          add_ribbons(
            data = line_df,
            x = ~x,
            ymin = ~lwr,
            ymax = ~upr,
            fillcolor = "rgba(35,76,122,0.15)",
            line = list(color = "rgba(0,0,0,0)"),
            hoverinfo = "skip",
            showlegend = FALSE
          ) |>
          add_lines(
            data = line_df,
            x = ~x,
            y = ~fit,
            line = list(color = "#234C7A", width = 2),
            hoverinfo = "skip",
            showlegend = FALSE
          )
      }
      
      fig <- fig |>
        add_markers(
          data = data_now,
          x = ~weekly_gaming_hours,
          y = ~sleep_latency,
          marker = list(
            color = input$point_color,
            size = 9,
            opacity = 0.65
          ),
          hovertemplate = paste(
            "Weekly gaming: %{x:.2f} hours",
            "<br>Sleep latency: %{y:.1f} minutes",
            "<extra></extra>"
          ),
          showlegend = FALSE
        ) |>
        layout(
          title = list(text = "Gaming Time vs. Sleep-Onset Latency"),
          xaxis = list(
            title = "Average weekly gaming time (hours)",
            range = c(0, isolate(input$latency_x_max))
          ),
          yaxis = list(
            title = "Sleep-onset latency (minutes)",
            range = c(0, isolate(input$latency_y_max))
          ),
          transition = list(duration = 0)
        ) |>
        config(displayModeBar = FALSE, responsive = TRUE)
      
      fig
    }
  })
  
  # ----------------------------------------------------------
  # Dynamic summary statistics
  # ----------------------------------------------------------
  
  output$summary_stats <- renderPrint({
    
    data_now <- filtered_df()
    
    cat("Number of responses:", nrow(data_now), "\n")
    
    
    if (input$plot_choice == "plot1") {
      
      cat("Mean weekly gaming hours:",
        round(mean(data_now$weekly_gaming_hours,
            na.rm = TRUE), 2), "\n")
      
      cat("Mean nightly sleep duration:",
        round(mean(data_now$sleep_hours_per_night,
            na.rm = TRUE), 2), "\n")
      
      
    } else if (input$plot_choice == "plot2") {
      
      cat("Mean bedtime gaming days:",
        round(mean(data_now$bedtime_gaming_days, na.rm = TRUE), 2), "\n")
      
      cat("Mean sleep quality:",
        round(mean(data_now$sleep_quality, na.rm = TRUE), 2),"\n")
      
      
    } else {
      
      cat("Mean weekly gaming hours:",
        round(mean(data_now$weekly_gaming_hours,
            na.rm = TRUE), 2), "\n")
      
      cat("Mean sleep-onset latency:",
        round(mean(data_now$sleep_latency,
            na.rm = TRUE), 2), "minutes\n" )}})
  
  
  output$model_results <- renderPrint({
    data_now <- filtered_df()
    
    # Select the gaming variable used by the current graph
    x_now <- if (input$plot_choice == "plot2") {
      data_now$bedtime_gaming_days
    } else {
      data_now$weekly_gaming_hours
    }
    
    # A regression association requires variation in the predictor
    validate(
      need(
        length(unique(x_now[is.finite(x_now)])) >= 2,
        paste(
          "Gaming time or frequency does not vary in this subgroup,",
          "so its association with sleep cannot be estimated.",
          "Descriptive summaries are shown above."
        )
      )
    )
    
    if (input$plot_choice == "plot1") {
      model <- lm(sleep_hours_per_night ~ weekly_gaming_hours,
        data = data_now)
      
      result <- summary(model)
      
      cat("Simple Linear Regression\n")
      cat("Outcome: Nightly sleep duration\n")
      cat("Predictor: Weekly gaming time\n\n")
      
      cat("Estimated slope:",
          round(coef(model)[2], 4), "\n")
      
      cat("p-value:",
          round(result$coefficients[2, 4], 4), "\n")
      
      cat("R-squared:",
          round(result$r.squared, 4), "\n")
      
    } else if (input$plot_choice == "plot2") {
      model <- lm(sleep_quality ~ bedtime_gaming_days, data = data_now)
      
      result <- summary(model)
      
      cat("Simple Linear Regression\n")
      cat("Outcome: Self-reported sleep quality\n")
      cat("Predictor: Bedtime gaming frequency\n\n")
      
      cat("Estimated slope:",
          round(coef(model)[2], 4), "\n")
      
      cat("p-value:",
          round(result$coefficients[2, 4], 4), "\n")
      
      cat("R-squared:",
          round(result$r.squared, 4), "\n")
      
    } else {
      m1 <- lm(
        sleep_latency ~ weekly_gaming_hours,
        data = data_now
      )
      
      m2 <- lm(
        sleep_latency ~ weekly_gaming_hours + caffeine_servings,
        data = data_now
      )
      
      m3 <- lm(
        sleep_latency ~ weekly_gaming_hours + non_gaming_screen_time,
        data = data_now
      )
      
      m4 <- lm(
        sleep_latency ~ weekly_gaming_hours +
          caffeine_servings +
          non_gaming_screen_time,
        data = data_now
      )
      
      aic_values <- AIC(m1, m2, m3, m4)
      delta_aic <- aic_values$AIC - min(aic_values$AIC)
      
      m4_result <- summary(m4)
      gaming_result <- m4_result$coefficients["weekly_gaming_hours", ]
      
      cat("Primary Multiple Linear Regression Model\n")
      cat("Outcome: Sleep-onset latency\n")
      cat("Predictors: Weekly gaming time, caffeine consumption,")
      cat(" and non-gaming screen time\n\n")
      
      cat(
        "Gaming coefficient:",
        round(gaming_result["Estimate"], 4),
        "\n"
      )
      
      cat(
        "Gaming p-value:",
        round(gaming_result["Pr(>|t|)"], 4),
        "\n"
      )
      
      cat(
        "Adjusted R-squared:",
        round(m4_result$adj.r.squared, 4),
        "\n\n"
      )
      
      cat("AIC Model Comparison\n\n")
      
      cat("Outcome for all models: Sleep-onset latency\n")
      cat("M1: Weekly gaming time\n")
      cat("M2: Weekly gaming time + caffeine consumption\n")
      cat("M3: Weekly gaming time + non-gaming screen time\n")
      cat("M4: Weekly gaming time + caffeine consumption",
          " + non-gaming screen time\n\n")
      
      aic_table <- data.frame(Model = c("M1", "M2", "M3", "M4"),
        df = aic_values$df,
        AIC = round(aic_values$AIC, 2),
        Delta_AIC = round(delta_aic, 2))
      
      print(aic_table, row.names = FALSE)
      
      best_model <- c("M1", "M2", "M3", "M4")[which.min(aic_values$AIC)]
      
      cat("\nLowest AIC:", best_model, "\n")
      
      cat("M4 is retained as the primary model because Research Question 3",
        " specifically asks for the association after accounting for",
        " caffeine consumption and non-gaming screen time before bed.\n")
      
      if (max(delta_aic) < 2) {
        cat("\nThe AIC values are very similar across all four",
            " candidate models (all Delta AIC < 2).\n")
      }
    }})
  
  # ----------------------------------------------------------
  # Dynamic interpretation
  # ----------------------------------------------------------
  
  output$plot_description <- renderText({
    data_now <- filtered_df()
    
    formula_now <- switch(input$plot_choice,
                          plot1 = sleep_hours_per_night ~ weekly_gaming_hours,
                          plot2 = sleep_quality ~ bedtime_gaming_days,
                          plot3 = sleep_latency ~ weekly_gaming_hours +
                            caffeine_servings + non_gaming_screen_time
    )
    
    variables <- all.vars(formula_now)
    data_now <- data_now[
      complete.cases(data_now[, variables, drop = FALSE]),
      , drop = FALSE
    ]
    x_name <- variables[2]
    
    if (length(unique(data_now[[x_name]])) < 2) {
      return(paste(
        "Gaming time or frequency does not vary in this subgroup,",
        "so its association with sleep cannot be estimated.",
        "Descriptive summaries are shown above."
      ))
    }
    
    model <- lm(formula_now, data = data_now)
    result <- summary(model)
    
    if (df.residual(model) <= 0 ||
        !x_name %in% rownames(result$coefficients)) {
      return("The selected data do not support estimation of this association.")
    }
    
    p_value <- result$coefficients[x_name, "Pr(>|t|)"]
    
    if (!is.finite(p_value)) {
      return("The selected data do not support a reliable regression test.")
    }
    
    topic <- switch(input$plot_choice,
                    plot1 = "weekly gaming time and nightly sleep duration",
                    plot2 = "bedtime gaming frequency and self-reported sleep quality",
                    plot3 = "weekly gaming time and the time taken to fall asleep"
    )
    
    evidence <- if (p_value < 0.05) {
      "provide statistical evidence of an association"
    } else {
      "do not provide clear statistical evidence of an association"
    }
    
    p_text <- if (p_value < 0.0001) {
      "< 0.0001"
    } else {
      paste0("= ", sprintf("%.4f", p_value))
    }
    
    slope <- unname(coef(model)[x_name])

    difference <- switch(
      input$plot_choice,
      plot1 = sprintf(
        paste("Students who reported 10 more hours of gaming per week",
              "were estimated to sleep %.1f %s per night on average."),
        abs(slope) * 10 * 60,
        if (slope >= 0) "minutes longer" else "fewer minutes"
      ),
      plot2 = sprintf(
        paste("Each additional day of bedtime gaming in the past 14 days",
              "was associated with a sleep quality rating %.2f points %s",
              "on the 1–10 scale, on average."),
        abs(slope),
        if (slope >= 0) "higher" else "lower"
      ),
      plot3 = sprintf(
        paste("At the same caffeine intake and non-gaming screen time,",
              "students who reported 10 more hours of gaming per week",
              "were estimated to take %.1f %s to fall asleep on average."),
        abs(slope) * 10,
        if (slope >= 0) "minutes longer" else "fewer minutes"
      )
    )

    paste0(
      "Among ", nobs(model), " respondents in this subgroup: ", difference,
      " The results ", evidence, " between ", topic, " (p ", p_text, "). ",
      "This observational survey cannot establish cause and effect."
    )
  })
  

  select_group <- function(g) {
    if (g == "gamers") df[df$gaming_days > 0, , drop=FALSE]
    else if (g == "non_gamers") df[df$gaming_days == 0, , drop=FALSE]
    else df
  }
  overview <- reactive({
    d <- select_group(input$ov_group)
    d <- d[d$caffeine_servings >= input$ov_caffeine[1] & d$caffeine_servings <= input$ov_caffeine[2] & d$sleep_quality >= input$ov_quality[1] & d$sleep_quality <= input$ov_quality[2], ,drop=FALSE]
    validate(need(nrow(d)>0,"No respondents match these filters.")); d
  })
  output$ov_cards <- renderUI({
    d <- overview()
    fluidRow(lapply(list(c("Responses",nrow(d)),c("Mean sleep hours",round(mean(d$sleep_hours_per_night),2)),c("Mean quality",round(mean(d$sleep_quality),2)),c("Mean latency (min)",round(mean(d$sleep_latency),2))),function(v) column(3,div(class="about-box",h4(v[1]),h2(v[2])))))
  })
  output$ov_hist <- renderPlotly({
    d <- overview(); v <- input$ov_var; label <- names(variable_labels)[match(v,variable_labels)]
    plot_ly(x=d[[v]],type="histogram",marker=list(color="#397CB7")) |> layout(title="Distribution",xaxis=list(title=label),yaxis=list(title="Count"))
  })
  output$ov_box <- renderPlotly({
    d <- overview(); v <- input$ov_var; label <- names(variable_labels)[match(v,variable_labels)]
    plot_ly(x=ifelse(d$gaming_days>0,"Gamers","Non-gamers"),y=d[[v]],type="box",boxpoints="outliers",marker=list(color="#397CB7")) |> layout(title="Distribution by gaming status",yaxis=list(title=label),xaxis=list(title=""))
  })
  output$ov_summary <- renderTable({
    d <- overview(); do.call(rbind,lapply(seq_along(variable_labels),function(i){x<-d[[variable_labels[[i]]]]; data.frame(Variable=names(variable_labels)[i],N=length(x),Mean=mean(x),SD=sd(x),Median=median(x),Q1=unname(quantile(x,.25)),Q3=unname(quantile(x,.75)),Min=min(x),Max=max(x))}))
  },digits=2)
  output$ov_corr <- renderPlotly({
    d <- overview(); validate(need(nrow(d)>=2,"At least two respondents are needed."))
    m <- suppressWarnings(cor(d[,unname(variable_labels)])); labs <- names(variable_labels)
    plot_ly(x=labs,y=labs,z=m,type="heatmap",zmin=-1,zmax=1,colorscale="RdBu",reversescale=TRUE) |> layout(margin=list(l=150,b=150),xaxis=list(tickangle=-45))
  })
  lab_data <- reactive({
    d <- select_group(input$lab_group)
    y <- switch(input$lab_q,q1="sleep_hours_per_night",q2="sleep_quality",q3="sleep_latency")
    x <- if(input$lab_q=="q2") "bedtime_gaming_days" else "weekly_gaming_hours"
    vars <- c(y,x,if(input$lab_q=="q3") c("caffeine_servings","non_gaming_screen_time"))
    d <- d[complete.cases(d[,vars,drop=FALSE]),,drop=FALSE]
    validate(need(nrow(d)>4 && length(unique(d[[x]]))>1,"Insufficient variation or sample size for regression in this subgroup."))
    list(d=d,y=y,x=x)
  })
  lab_models <- reactive({
    a <- lab_data(); terms <- list(m1=a$x)
    if(input$lab_q=="q3") terms <- c(terms,list(m2=c(a$x,"caffeine_servings"),m3=c(a$x,"non_gaming_screen_time"),m4=c(a$x,"caffeine_servings","non_gaming_screen_time")))
    lapply(terms,function(t) lm(reformulate(t,response=a$y),data=a$d))
  })
  lab_fit <- reactive({
    m <- lab_models(); f <- if(input$lab_q=="q3") m[[input$lab_model]] else m[[1]]
    validate(need(df.residual(f)>0 && f$rank==length(coef(f)),"Model is rank deficient or has insufficient residual degrees of freedom.")); f
  })
  coef_table <- reactive({
    f <- lab_fit(); sm <- summary(f)$coefficients; ci <- confint(f,level=input$lab_ci/100)
    data.frame(Term=rownames(sm),Estimate=sm[,1],SE=sm[,2],Lower=ci[,1],Upper=ci[,2],P_value=sm[,4],row.names=NULL)
  })
  output$lab_table <- renderTable(coef_table(),digits=4)
  output$lab_coef <- renderPlotly({
    t <- coef_table(); t <- t[t$Term!="(Intercept)",,drop=FALSE]
    plot_ly(t,x=~Estimate,y=~Term,type="scatter",mode="markers",error_x=list(type="data",symmetric=FALSE,array=t$Upper-t$Estimate,arrayminus=t$Estimate-t$Lower),marker=list(size=10,color="#397CB7")) |> layout(xaxis=list(title="Coefficient (original units)"),shapes=list(list(type="line",x0=0,x1=0,y0=0,y1=1,yref="paper",line=list(dash="dot"))),margin=list(l=165))
  })
  comparison <- reactive({
    ms <- lab_models(); vals <- sapply(ms,AIC)
    data.frame(Model=names(ms),AIC=unname(vals),Delta_AIC=unname(vals-min(vals)),Adjusted_R2=sapply(ms,function(f) summary(f)$adj.r.squared),Residual_SD=sapply(ms,function(f) summary(f)$sigma),N=sapply(ms,nobs),row.names=NULL)
  })
  output$lab_compare <- renderTable(comparison(),digits=3)
  output$lab_aic <- renderPlotly({t<-comparison();plot_ly(t,x=~Model,y=~Delta_AIC,type="bar",marker=list(color="#397CB7")) |> layout(title="Delta AIC (lower is better)",yaxis=list(title="Delta AIC"))})
  output$lab_pred <- renderPrint({
    a<-lab_data(); f<-lab_fit(); x<-input$lab_x; req(is.finite(x)); r<-range(a$d[[a$x]])
    validate(need(x>=r[1] && x<=r[2],paste("Enter a predictor within the observed range:",paste(r,collapse=" to "))))
    nd<-as.data.frame(lapply(a$d[,all.vars(formula(f))[-1],drop=FALSE],median)); nd[[a$x]]<-x
    print(nd); print(predict(f,newdata=nd,interval="confidence",level=input$lab_ci/100))
  })
  output$diag_resid <- renderPlotly({f<-lab_fit();plot_ly(x=fitted(f),y=residuals(f),type="scatter",mode="markers") |> layout(title="Residuals vs fitted",xaxis=list(title="Fitted values"),yaxis=list(title="Residuals"),shapes=list(list(type="line",x0=0,x1=1,xref="paper",y0=0,y1=0,line=list(dash="dot"))))})
  output$diag_qq <- renderPlotly({f<-lab_fit();r<-rstandard(f);r<-r[is.finite(r)];validate(need(length(r)>1,"Not enough finite standardized residuals."));q<-qqnorm(r,plot.it=FALSE); z<-quantile(r,c(.25,.75)); slope<-diff(z)/diff(qnorm(c(.25,.75))); intercept<-z[1]-slope*qnorm(.25); plot_ly(x=q$x,y=q$y,type="scatter",mode="markers") |> add_lines(x=range(q$x),y=intercept+slope*range(q$x),inherit=FALSE,showlegend=FALSE) |> layout(title="Normal Q-Q",xaxis=list(title="Theoretical quantiles"),yaxis=list(title="Standardized residuals"),showlegend=FALSE)})
  output$diag_cook <- renderPlotly({f<-lab_fit(); cd<-cooks.distance(f);plot_ly(x=seq_along(cd),y=cd,type="bar") |> layout(title="Cook's distance",xaxis=list(title="Observation index"),yaxis=list(title="Cook's D"),shapes=list(list(type="line",x0=0,x1=1,xref="paper",y0=4/nobs(f),y1=4/nobs(f),line=list(dash="dot",color="red"))))})
  output$diag_scale <- renderPlotly({f<-lab_fit();plot_ly(x=fitted(f),y=sqrt(abs(rstandard(f))),type="scatter",mode="markers") |> layout(title="Scale-location",xaxis=list(title="Fitted values"),yaxis=list(title="Sqrt |standardized residual|"))})
  output$diag_sensitivity <- renderTable({
    f<-lab_fit(); a<-lab_data(); cd<-cooks.distance(f); keep<-is.finite(cd) & cd<=4/nobs(f); d<-model.frame(f)
    stat<-function(m,label){sm<-summary(m)$coefficients; if(!a$x %in% rownames(sm)) return(data.frame(Sample=label,N=nobs(m),Slope=NA_real_,P_value=NA_real_));data.frame(Sample=label,N=nobs(m),Slope=sm[a$x,1],P_value=sm[a$x,4])}
    full<-stat(f,"Full sample"); if(sum(keep)<=length(coef(f)) || length(unique(d[[a$x]][keep]))<2) return(full)
    reduced<-lm(formula(f),data=d[keep,,drop=FALSE]); if(reduced$rank<length(coef(reduced))) return(full)
    rbind(full,stat(reduced,"Excluding flagged observations"))
  },digits=4)

}

# ------------------------------------------------------------
# 4. Run app
# ------------------------------------------------------------

shinyApp(ui = ui, server = server)
