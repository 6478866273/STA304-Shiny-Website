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
      
      cat("Primary model for Research Question 3: M4\n")
      
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
    
    adjustment <- if (input$plot_choice == "plot3") {
      "This model accounts for caffeine consumption and non-gaming screen time. "
    } else {
      ""
    }
    
    paste0(
      "Among ", nobs(model), " respondents in the current subgroup, the results ",
      evidence, " between ", topic, " (p ", p_text, "). ",
      adjustment,
      "A lack of statistical evidence does not prove there is no association. ",
      "This observational survey cannot establish cause and effect."
    )
  })
  
}

# ------------------------------------------------------------
# 4. Run app
# ------------------------------------------------------------

shinyApp(ui = ui, server = server)
