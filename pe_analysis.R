# ═══════════════════════════════════════════════════════════
# PROJECT 3: PE PARTICIPATION & INCLUSION ANALYSIS
# ═══════════════════════════════════════════════════════════

# Load libraries
library(tidyverse)
library(sqldf)

# Load data (using file chooser - works every time!)
pe_data <- read.csv(file.choose())

# Verify it loaded
cat("Data loaded successfully! Rows:", nrow(pe_data), "\n")
head(pe_data)


# Explore it
head(pe_data)        # First 6 rows
str(pe_data)         # Structure
summary(pe_data)     # Summary statistics

# How many students have disabilities?
table(pe_data$has_disability)

# Average PE frequency
mean(pe_data$pe_frequency)

# Average teacher support rating
mean(pe_data$teacher_support)

# Most common barrier
table(pe_data$main_barrier)

# Average confidence level
mean(pe_data$confidence_level)

#Q1: Do students with disabilities participate in PE less 
#than students without?
q1_disability_participation<-sqldf("SELECT has_disability, AVG(pe_frequency) AS avg_participation
      FROM pe_data
      GROUP BY has_disability")
# INSIGHT: Students with disabilities participate at nearly the same 
# frequency as students without disabilities (2.92 vs 2.97 times/week).
# This suggests inclusive PE provision in terms of ACCESS, though 
# quality of experience may differ (explored in later questions).

#QUESTION 2:
"What are the main barriers, and do they differ by disability status?"
q2_barriers<-sqldf("SELECT has_disability, main_barrier, COUNT(*) 
AS count
      FROM pe_data
      GROUP BY has_disability, main_barrier
      ORDER BY has_disability, count DESC")
# INSIGHT: Students with disabilities face different barriers:
# - TOP barrier: "No suitable activities" (26% vs 16% for non-disabled)
# - Accessibility gaps: "No accessible facilities" affects 18% vs 15%
# - Confidence is top barrier for non-disabled (21%) but #3 for disabled (16%)
# 
# RECOMMENDATION: Address structural barriers (programming, facilities) 
# not just individual confidence for students with disabilities.

#QUESTION 3:
#"Is there a relationship between teacher support and student confidence?"
q3_support_confidence<-sqldf("SELECT teacher_support, AVG(confidence_level) AS avg_confidence
FROM pe_data
GROUP BY teacher_support
ORDER BY teacher_support")

# INSIGHT: No clear linear relationship found. Lowest teacher support 
# (1) correlates with HIGHEST confidence (3.38), while moderate support 
# (2) shows lowest confidence (2.85). Suggests confidence driven by 
# other factors beyond teacher support alone.

#QUESTION 4:
#"Do private vs state schools have different participation rates?"
q4_school_participation<-sqldf("SELECT school_type, AVG(pe_frequency)
AS participation_rate
FROM pe_data
GROUP BY school_type
ORDER BY school_type")

# INSIGHT: Private schools show slightly higher PE participation 
# (3.03 times/week) compared to state schools (2.95 times/week), 
# a difference of 0.08 sessions per week (3% difference).
#
# This modest gap could reflect:
# - Greater PE time allocation in private schools
# - Better facilities/resources enabling more sessions
# - Smaller class sizes allowing more participation opportunities
#
# However, the difference is small, suggesting relatively equitable 
# PE provision across school types in terms of frequency.

#QUESTION 5:
#"Which regions have the highest/lowest participation?
q5_regional_participation<-sqldf("SELECT region, ROUND(AVG(pe_frequency), 2)
AS participation_rate
      FROM pe_data
      GROUP BY region
      ORDER BY AVG(pe_frequency) DESC")

#INSIGHT: Minimal regional variation in PE participation:
  # England highest (3.05), Scotland lowest (2.93) - only 0.12 
  # sessions/week difference (4%). This suggests relatively equitable 
  # PE provision across UK regions, with all averaging ~3 sessions/week.

#QUESTION 6:
#"Does sports club membership relate to PE confidence?"
q6_club_confidence<-sqldf("SELECT sports_clubs, 
ROUND(AVG(confidence_level), 2) AS pe_confidence
      FROM pe_data
      GROUP BY sports_clubs
      ORDER BY sports_clubs")

# INSIGHT: Positive relationship between club membership and confidence:
# 3 clubs → 3.50 confidence (highest)
# 2 clubs → 3.33
# 1 club  → 2.93 (lowest)
# 0 clubs → 3.10 (moderate)
#
# Pattern suggests: More club involvement → higher confidence
# (or confident students join more clubs - correlation, not causation)

#QUESTION 7:
#"For students with disabilities, what's the 
#main barrier preventing participation?"

q7_disability_barriers<-sqldf("SELECT main_barrier, COUNT(*) AS barrier_count
       FROM pe_data
       WHERE has_disability = 'Yes'
       GROUP BY main_barrier
       ORDER BY COUNT(*) DESC")

# INSIGHT: For students with disabilities, the main barriers are:
# 1. No suitable activities (26%) - Planning gap
# 2. No accessible facilities (18%) - Infrastructure gap
# 3. Lack of confidence (16%) - Psychological
#
# CRITICAL FINDING: Structural barriers (planning + facilities) 
# account for 44% of barriers, far exceeding psychological factors.
# This indicates the need for systemic changes beyond just teacher 
# attitudes - requires adapted curriculum and accessible infrastructure.

#CHART 1: BARRIERS BY DISABILITY STATUS

barriers_data <- sqldf("
  SELECT has_disability, main_barrier, COUNT(*) AS count
  FROM pe_data
  GROUP BY has_disability, main_barrier
  ORDER BY has_disability, count DESC
")

barriers_data

library(ggplot2)
library(ggplot2)

ggplot(barriers_data, aes(x = main_barrier, y = count, 
                          fill = has_disability)) +
  geom_col(position = "dodge") +
  coord_flip() +
  labs(
    title = "Barriers to PE Participation by Disability Status",
    x = "Barrier Type",
    y = "Number of Students",
    fill = "Has Disability"
  ) +
  theme_minimal()

# Save the chart
ggsave("barriers_chart.png", width = 10, height = 6)

#CHART 2: CONFIDENCE BY SPORTS CLUBS

clubs_confidence <- sqldf("
  SELECT sports_clubs, 
         ROUND(AVG(confidence_level), 2) AS avg_confidence
  FROM pe_data
  GROUP BY sports_clubs
  ORDER BY sports_clubs
")

clubs_confidence

ggplot(clubs_confidence, aes(x = sports_clubs, y = avg_confidence)) +
  geom_line(color = "darkblue", size = 1.2) +
  geom_point(color = "darkblue", size = 3) +
  labs(
    title = "PE Confidence by Sports Club Membership",
    x = "Number of Sports Clubs",
    y = "Average Confidence Level"
  ) +
  theme_minimal()

ggsave("clubs_confidence_chart.png", width = 10, height = 6)

#CHART 3: REGIONAL PARTICIPATION
regional_participation<-sqldf("SELECT region, ROUND(AVG(pe_frequency), 2)
AS participation_rate
      FROM pe_data
      GROUP BY region
      ORDER BY AVG(pe_frequency) DESC")

ggplot(regional_participation, aes(x=region, y=participation_rate))+
  geom_col()+labs(
    title="Regional Participation",
    x="Region",
    y="Participation Rate"
  )+
  theme_minimal()

ggsave("regional_participation_chart.png", width = 10, height = 6)

list.files(pattern = "\\.png$")
