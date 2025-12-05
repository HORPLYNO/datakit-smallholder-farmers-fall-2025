library(tidyverse)
library(arrow)
library(corrgram)
library(data.table)
library(qs)
library(naniar)
library(text2vec)
library(tm)
library(textstem)
library(ldatuning)
library(Matrix)

agridata <- fread("data/agridata.csv", header = T)
str(agridata)

# Filter only English data
agridata_en <- agridata %>% filter(question_language == "eng", response_language == "eng")
agridata_en <- agridata_en %>% select(-c(question_language, response_language)) # language fields are not required now
agridata_en <- as.data.frame(agridata_en)
str(agridata_en)

qsave(agridata_en, "agridata_en.qs")
rm(agridata_en)

agridata_en <- qread("agridata_en.qs")

# Basic Data Understanding
summary(agridata_en)
colnames(agridata_en)

## Number of unique questions
n_distinct(agridata_en$question_id)/nrow(agridata_en) # Only 25% are different questions
top_20_questions <- sort(table(as.factor(agridata_en$question_id)), decreasing=T)[1:20] # 4 questions have been answered more than 1000 times
top_20_questions

df_plot <- data.frame(
  question_id = names(top_20_questions), 
  count = as.numeric(top_20_questions)   
)

# Convert question_id to a factor to ensure the order is maintained
# Since the input vector was already sorted, we use its current order for the levels.
df_plot$question_id <- factor(df_plot$question_id, levels = df_plot$question_id)

# Generate the plot
ggplot(df_plot, aes(x = question_id, y = count)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(
    title = "Top 20 Most Frequent Questions",
    x = "Question ID",
    y = "Frequency"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))

# Frequency distribution of questions
question_frequencies <- agridata_en %>%
  count(question_id, name = "count")

plot <- ggplot(question_frequencies, aes(x = count)) +
  # Use geom_histogram to create bins for the question counts (the X-axis).
  # You can adjust 'binwidth' to change the grouping of the counts.
  # binwidth = 10 means 10 frequencies are grouped together (e.g., 1-10, 11-20, etc.)
  geom_histogram(binwidth = 10, fill = "#54278f", color = "white") +
  
  # Set the Y-axis (Number of Unique Questions) to a logarithmic scale (Base 10)
  scale_y_log10(
    labels = scales::comma # Formats the log-scale labels nicely (e.g., 100,000 instead of 1e+05)
  ) +
  # Use scale_x_continuous to set the lower limit at 0 or 1
  scale_x_continuous(limits = c(1, NA)) +
  
  labs(
    title = "Log-Scale Distribution of Question Counts",
    subtitle = "Histogram of Question Frequencies (Binwidth = 10)",
    x = "Number of Times a Question was Asked (Count)",
    y = "Number of Unique Questions (Log Scale)"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold"))

# Question Topic
table(agridata_en$question_topic)
agridata_en$question_topic<-factor(agridata_en$question_topic)

top_20_question_topics <- sort(table(agridata_en$question_topic), decreasing=T)[2:21] # 4 questions have been answered more than 1000 times
top_20_question_topics

df_plot <- data.frame(
  question_topic = names(top_20_question_topics), 
  count = as.numeric(top_20_question_topics)   
)

df_plot$question_topic <- factor(df_plot$question_topic, levels = df_plot$question_topic)

# Generate the plot
ggplot(df_plot, aes(x = question_topic, y = count)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(
    title = "Top 20 Most Frequent Question Topics",
    x = "Question Topics",
    y = "Frequency"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))


colnames(agridata_en)

# User Type
table(agridata_en$question_user_type)
table(agridata_en$response_user_type)
agridata_en$question_user_type <- NULL # All users are farmer, irrelevant column
agridata_en$response_user_type <- NULL # All users are farmer, irrelevant column

# User Status
table(agridata_en$question_user_status)
table(agridata_en$response_user_status)

agridata_en$question_user_status <- as.factor(agridata_en$question_user_status)
agridata_en$response_user_status <- as.factor(agridata_en$response_user_status)

question_tab <- table(agridata_en$question_user_status)
response_tab <- table(agridata_en$response_user_status)

df <- data.frame(
  status = names(question_tab),
  question = as.numeric(question_tab),
  response = as.numeric(response_tab)
)

# Reshape to long format for ggplot
df_long <- pivot_longer(df, cols = c("question", "response"),
                        names_to = "type", values_to = "count")

# Plot
ggplot(df_long, aes(x = status, y = count, fill = type)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "User Status Comparison: Questions vs Responses",
       x = "User Status",
       y = "Count",
       fill = "Type") +
  theme_minimal()

# Country code
table(agridata_en$question_user_country_code)
table(agridata_en$response_user_country_code)

# Gender
agridata_en$question_user_gender <- as.factor(agridata_en$question_user_gender)
agridata_en$response_user_gender <- as.factor(agridata_en$response_user_gender)
sum(agridata_en$question_user_gender=='')/nrow(agridata_en)
sum(agridata_en$response_user_gender=='')/nrow(agridata_en)

summary(agridata_en)

# Time of question and response
summary(agridata_en$question_sent)
summary(agridata_en$response_sent)
str(agridata_en$response_sent)

# Create daily counts for questions
question_daily <- agridata_en %>%
  mutate(date = as.Date(question_sent)) %>%
  count(date) %>%
  mutate(type = "question")

# Create daily counts for responses
response_daily <- agridata_en %>%
  mutate(date = as.Date(response_sent)) %>%
  count(date) %>%
  mutate(type = "response")

# Combine both
daily_combined <- bind_rows(question_daily, response_daily)

# Plot
ggplot(daily_combined, aes(x = date, y = n, color = type)) +
  geom_line() +
  labs(title = "Daily Volume: Questions vs Responses",
       x = "Date", y = "Count", color = "Type") +
  theme_minimal()

# Handling Missing data
summary(agridata_en)
agridata_en <- agridata_en %>%
  mutate(across(where(is.factor), as.character)) %>%  # Convert factors to character
  mutate(across(where(is.character), ~na_if(.x, ""))) # Replace "" with NA

miss_var_summary(agridata_en)

## Removing gender and dob due to high missing%
agridata_en <- agridata_en %>% 
  select(-c(question_user_gender, response_user_gender, 
            question_user_dob, response_user_dob))

## Removing User creation date 
agridata_en$question_user_created_at <- NULL
agridata_en$response_user_created_at <- NULL
agridata_en$response_user_status <- NULL
agridata_en$question_user_status <- NULL

summary(agridata_en)


# Converting data types
agridata_en$question_user_status <- factor(agridata_en$question_user_status)
agridata_en$question_user_country_code <- factor(agridata_en$question_user_country_code)
agridata_en$response_user_status <- factor(agridata_en$response_user_status)
agridata_en$response_user_country_code <- factor(agridata_en$response_user_country_code)


# Feature Engineering
## Breaking down Question and response times
str(agridata_en$question_sent)
agridata_en$question_sent_year <- year(agridata_en$question_sent)
agridata_en$question_sent_month <- month(agridata_en$question_sent)
agridata_en$response_sent_year <- year(agridata_en$response_sent)
agridata_en$response_sent_month <- month(agridata_en$response_sent)
agridata_en$response_time_taken <- as.numeric(difftime(agridata_en$response_sent, agridata_en$question_sent, units = "days"))
str(agridata_en$response_time_taken)
summary(agridata_en$response_time_taken)

## Removing question_sent and response_sent
agridata_en$response_sent <- NULL
agridata_en$question_sent <- NULL

str(agridata_en)

## Plot to showcase question frequency across the year
monthly_totals <- agridata_en %>%
  group_by(question_sent_month) %>%
  summarise(total_questions = n(), .groups = "drop")

monthly_totals$month_label <- month.name[monthly_totals$question_sent_month]

ggplot(monthly_totals, aes(x = reorder(month_label, question_sent_month), y = total_questions)) +
  geom_col(fill = "steelblue") +
  labs(
    title = "Total Questions Asked by Month (All Years Combined)",
    x = "Month",
    y = "Number of Questions"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))

## Plot with faceting by year
monthly_by_year <- agridata_en %>%
  group_by(question_sent_year, question_sent_month) %>%
  summarise(total_questions = n(), .groups = "drop") %>%
  mutate(month_label = factor(month.name[question_sent_month], levels = month.name))

ggplot(monthly_by_year, aes(x = month_label, y = total_questions)) +
  geom_col(fill = "steelblue") +
  facet_wrap(~ question_sent_year, ncol = 3) +
  labs(
    title = "Monthly Question Volume Faceted by Year",
    x = "Month",
    y = "Number of Questions"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


## Plot with faceting by country
monthly_by_country <- agridata_en %>%
  group_by(question_user_country_code, question_sent_month) %>%
  summarise(total_questions = n(), .groups = "drop") %>%
  mutate(month_label = factor(month.name[question_sent_month], levels = month.name))

ggplot(monthly_by_country,
       aes(x = month_label, y = total_questions, color = question_user_country_code, group = question_user_country_code)) +
  geom_line() +
  geom_point() +
  scale_y_continuous(
    limits = c(0, 1000000),       # set min/max
    labels = scales::comma      # format with commas
  )+
  labs(
    title = "Monthly Question Volume by Country",
    x = "Month",
    y = "Number of Questions",
    color = "Country"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# LDA
## Creating a new dataframe with just the question ID and question content
lda_input <- agridata_en %>%
  select(question_id, question_content) %>%
  distinct(question_id, .keep_all = TRUE) %>%
  filter(!is.na(question_content))
str(lda_input)

## Data Preprocessing
custom_stopwords <- c(stopwords("en"), "q", "question", "what", "where", "why", "how", "when", "who", "which", "whom", "whose", "can", "ask")

prep_fun <- function(text) {
  text %>%
    tolower() %>%
    removePunctuation() %>%
    str_replace_all("^q\\s*-*", "") %>%
    removeNumbers() %>%
    removeWords(custom_stopwords) %>%
    stripWhitespace() %>%
    lemmatize_strings()
}

lda_input_clean <- lda_input %>%
  mutate(clean_text = prep_fun(question_content))

## Tokenisation and DTM
tokens <- word_tokenizer(lda_input_clean$clean_text)

it <- itoken(tokens, progressbar = TRUE)
vocab <- create_vocabulary(it) %>%
  prune_vocabulary(term_count_min = 10, doc_proportion_max = 0.5)

vocab %>%
  arrange(desc(term_count)) %>%
  head(50)

vectorizer <- vocab_vectorizer(vocab)
dtm <- create_dtm(it, vectorizer)
dtm <- dtm[Matrix::rowSums(dtm) > 0, ]

set.seed(123)
sample_ids <- sample(1:nrow(dtm), 50000)   # 50k docs
dtm_sample <- dtm[sample_ids, ]
dtm_sample <- dtm_sample[Matrix::rowSums(dtm_sample) > 0, ]

## Topic Selection
result <- FindTopicsNumber(
  dtm_sample,                                # your document-term matrix
  topics = seq(5, 20, by = 1),        # test topic numbers from 5 to 20
  metrics = c("Griffiths2004", "CaoJuan2009", "Arun2010"),
  method = "Gibbs",                   # sampling method
  control = list(seed = 20),          # reproducibility
  verbose = TRUE
)

FindTopicsNumber_plot(result)

lda_model <- LDA$new(n_topics = 10, doc_topic_prior = 0.1, topic_word_prior = 0.01)
doc_topic_distr <- lda_model$fit_transform(dtm, n_iter = 1000)

topic_assignments <- data.frame(
  question_id = lda_input_clean$question_id,
  topic = max.col(doc_topic_distr)  # most probable topic per document
)

agridata_en <- agridata_en %>%
  left_join(topic_assignments, by = "question_id")

## Top Words and Topic labelling
top_words <- lda_model$get_top_words(n = 10, lambda = 1)

topic_labels <- data.frame(
  topic = 1:nrow(top_words),
  label = apply(top_words, 1, function(words) paste(words, collapse = ", "))
)

topic_distribution <- as.data.frame(doc_topic_distr)
topic_distribution$dominant_topic <- max.col(doc_topic_distr)

topic_counts <- topic_distribution %>%
  count(dominant_topic) %>%
  rename(topic = dominant_topic, count = n) %>%
  left_join(topic_labels, by = "topic")


ggplot(topic_counts, aes(x = reorder(topic, count), y = count)) +
  geom_col(fill = "#2ECC71") +
  coord_flip() +
  labs(
    title = "LDA Topic Distribution",
    x = "Topic",
    y = "Number of Questions"
  ) +
  theme_minimal()

## Checking for Seasonality in the questions
topic_month_counts <- agridata_en %>%
  filter(!is.na(topic), !is.na(question_sent_month)) %>%
  group_by(question_sent_year, question_sent_month, topic) %>%
  summarise(count = n(), .groups = "drop")

ggplot(topic_month_counts, aes(x = question_sent_month, y = count, color = factor(topic))) +
  geom_line() +
  facet_wrap(~question_sent_year, scales = "free_y") +
  labs(
    title = "Seasonal Trends in Topics",
    x = "Month",
    y = "Number of Questions",
    color = "Topic"
  ) +
  theme_minimal()

ggplot(topic_month_counts, aes(x = question_sent_month, y = factor(topic), fill = count)) +
  geom_tile() +
  facet_wrap(~question_sent_year) +
  scale_fill_gradient(low = "white", high = "#2ECC71") +
  labs(
    title = "Seasonal Heatmap of Topics",
    x = "Month",
    y = "Topic",
    fill = "Count"
  ) +
  theme_minimal()

topic_labels <- c(
  "Crop cultivation basics",     # Topic 1
  "Poultry farming",             # Topic 2
  "Crop management & harvest",   # Topic 3
  "Starting a farm/business",    # Topic 4
  "Market & pricing",            # Topic 5
  "Crop protection",             # Topic 6
  "Other livestock & community", # Topic 7
  "Platform interactions",       # Topic 8
  "Banana/soil management",      # Topic 9
  "Livestock & dairy"            # Topic 10
)

agridata_en$topic_label <- topic_labels[agridata_en$topic]
table(agridata_en$topic_label)

topic_month_counts <- agridata_en %>%
  filter(!is.na(topic_label), !is.na(question_sent_month)) %>%
  group_by(question_sent_year, question_sent_month, topic_label) %>%
  summarise(count = n(), .groups = "drop")

ggplot(topic_month_counts, aes(x = question_sent_month, y = count, color = topic_label)) +
  geom_line() +
  facet_wrap(~question_sent_year, scales = "free_y") +
  labs(
    title = "Seasonal Trends in Farmer Questions by Topic",
    x = "Month",
    y = "Number of Questions",
    color = "Topic"
  ) +
  theme_minimal()
