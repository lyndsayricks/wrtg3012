library(tidyverse)

# https://github.com/urban-m/elev/blob/master/data_extraction/get_uvulars_ejectives.md
setwd("/home/lyndsay/docs/contribution")
phoible <- read_csv("phoible.csv", col_types = c(InventoryID = "i", Marginal = "l", .default = "c"))
languoids <- read.csv("languoid.csv", stringsAsFactors = FALSE)
geo <- read.csv("languages_and_dialects_geo.csv", stringsAsFactors = FALSE)
phoible <- left_join(phoible, languoids, by = c("Glottocode" = "id"))
phoible <- left_join(phoible, geo)
rm(geo, languoids)

index <- phoible %>%
  select(InventoryID, Glottocode, ISO6393, name, LanguageName, SpecificDialect, Source, family_id, level, latitude, longitude, country_ids, macroarea) %>%
  distinct()

index <- index %>% rename(GlottologName = name, PhoibleName = LanguageName)

ejectives <- phoible %>% filter(grepl("ʼ", Phoneme))
viable_ejectives <- phoible %>% filter(sonorant == "-" & continuant == "-" & approximant == "-" & nasal == "-" & consonantal == "+")

ejective_counts <- ejectives %>%
  group_by(InventoryID) %>%
  summarize(Ejectives = n())
ejective_marginals <- ejectives %>%
  filter(Marginal) %>%
  group_by(InventoryID) %>%
  summarize(Marginal_Ejective = n())

viable_ejective_counts <- viable_ejectives %>%
  group_by(InventoryID) %>%
  summarize(Phonemes = n())

together <- left_join(ejective_counts, viable_ejective_counts, by = "InventoryID")
together$Ratios <- together$Ejectives / together$Phonemes

df <- left_join(index, together, by = "InventoryID")
df <- left_join(df, ejective_marginals)
rm(ejective_counts, ejective_marginals, viable_ejective_counts, ejectives, viable_ejectives, index, together, phoible)
df$has_ejectives <- !is.na(df$Ejectives)
df$Ejectives[is.na(df$Ejectives)] <- 0
df$Marginal_Ejective[is.na(df$Marginal_Ejective)] <- 0
df$Ratios[is.na(df$Ratios)] <- 0

glottolog.geo <- read.csv('languages_and_dialects_geo.csv')
languages.geo <- glottolog.geo %>% select(glottocode, longitude, latitude) %>% rename(lon=longitude, lat=latitude)
languages.geo <- languages.geo %>% filter(!is.na(lon) & !is.na(lat))
rm(glottolog.geo)

write.csv(df, "ejectives.csv")
write.csv(languages.geo, "geography.csv")