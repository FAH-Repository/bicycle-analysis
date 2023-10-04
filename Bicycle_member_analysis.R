         



files <- list.files(pattern="*.csv")
mainDF <- files %>% map_dfr(read.csv) 
head(mainDF)

no_dups <- mainDF %>%
  distinct(ride_id, .keep_all = TRUE)

mainDF$start_time <- ymd_hms(mainDF$started_at)
mainDF$end_time <- ymd_hms(mainDF$ended_at)
str(mainDF)


mainDF <- mainDF %>%
  mutate(ride_time_m = as.numeric(mainDF$end_time - mainDF$start_time) / 60)
summary(mainDF$ride_time_m)


mainDF <- mainDF %>%
  mutate(year_month = paste(strftime(mainDF$start_time, "%Y"),
                            "-",
                            strftime(mainDF$start_time, "%m"),
                            paste("(",strftime(mainDF$star_time, "%b"), ")", sep="")))
unique(mainDF$year_month)

mainDF <- mainDF %>%
  mutate(weekday = paste(strftime(mainDF$end_time, "%u"), "-", strftime(mainDF$end_time, "%a")))
unique(mainDF$weekday)

mainDF <- mainDF %>%
  mutate(start_hour = strftime(mainDF$end_time, "%H"))
unique(mainDF$start_hour)

mainDF %>%
  write.csv("cleaned_cycles.csv")
cycle_data <- mainDF
  
ggplot(cycle_data, aes(member_casual, fill=member_casual)) +
    geom_bar() +
    labs(x="Casuals vs Members", title="Distribution of casuals and members")

ggplot(cycle_data, aes(member_casual, fill=rideable_type)) +
  geom_bar() +
  labs(x="Casuals vs Members", title="Distribution of casuals and members")

cycle_data %>% filter(member_casual == "casual") %>% pull(ride_time_m) %>% mean()
cycle_data %>% filter(member_casual == "member") %>% pull(ride_time_m) %>% mean()

ggplot(cycle_data, aes(member_casual, fill=weekday)) +
  geom_bar() +
  labs(x="Casuals vs Members", title="Most common rider days comparison")

casual_weekend <- cycle_data %>% filter(member_casual == "casual") %>% filter(weekday== "6 - Sat" | weekday == "7 - Sun" ) %>%count(weekday)  
member_weekend <- cycle_data %>% filter(member_casual == "member") %>% filter(weekday== "6 - Sat" | weekday == "7 - Sun" )  %>%count(weekday)
casual_weekday <-cycle_data %>% filter(member_casual == "casual") %>% filter(!weekday %in% c("6 - Sat") & !weekday %in% c("7 - Sun") )  %>%count(weekday)
member_weekday <- cycle_data %>% filter(member_casual == "member") %>% filter(!weekday %in% c("6 - Sat") & !weekday %in% c("7 - Sun") )  %>%count(weekday)

cycle_data %>%
  ggplot(aes(year_month, fill=member_casual)) +
  geom_bar() +
  labs(x="Month",y="Rides", title="Distribution of rides by month")+
  coord_flip()

cycle_data %>%
  group_by(start_hour) %>%
  summarise(count= length(ride_id),
  '%' = (length(ride_id) / nrow(cycle_data)) * 100,
  'members' = (sum(member_casual == "member") / length(ride_id)) * 100,
  'casual' = (sum(member_casual == "casual") / length(ride_id)) * 100)

cycle_data %>%
  ggplot(aes(start_hour, fill=member_casual))+
  labs(x="Hours 0-23", title="Rides by hour")+
  geom_bar() +
  facet_wrap(~ weekday)



