# Analyses
library(dplyr)

ejectives <- read.csv("ejectives.csv")
ejectives$family_id <- as.factor(ejectives$family_id)
ejectives$macroarea <- as.factor(ejectives$macroarea)
ejectives <- ejectives %>% filter(level == "language")
ejectives <- ejectives %>% distinct(Glottocode, .keep_all=TRUE)

yes_ejectives <- ejectives %>% filter(has_ejectives == TRUE)
no_ejectives <- ejectives %>% filter(has_ejectives == FALSE)

elev_test <- wilcox.test(yes_ejectives$elevation, no_ejectives$elevation, alternative = "greater")
elev_test[["p.value"]]
temp_test <- wilcox.test(yes_ejectives$avg_temp, no_ejectives$avg_temp, alternative = "less")
temp_test[["p.value"]]
precip_test <- wilcox.test(yes_ejectives$avg_precipitation, no_ejectives$avg_precipitation, alternative = "less")
precip_test[["p.value"]]
range_test <- wilcox.test(yes_ejectives$annual_temp_range, no_ejectives$annual_temp_range, alternative = "greater")
range_test[["p.value"]]

# is there a relationship between family and elevation? (there is)
summary(aov(elevation ~ family_id, data=ejectives))
# is there a relationship between macroarea and elevation? (yes)
summary(aov(elevation ~ macroarea, data=ejectives))
# is there a relationship between elevation and average temp? (yes)
summary(lm(avg_temp ~ elevation, data=ejectives))
# is there a relationship between elevation and temp range? (yes albeit minimal R^2)
summary(lm(annual_temp_range ~ elevation, data=ejectives))
# is there a relationship between elevation and precipitation? (yes but again minimal R^2)
summary(lm(avg_precipitation ~ elevation, data=ejectives))
# is there a relationship between precipitation and temp? (yes)
summary(lm(avg_precipitation ~ avg_temp, data=ejectives))
# is there a relationship between precipitation and temp range? (yes)
summary(lm(avg_precipitation ~ annual_temp_range, data=ejectives))
# is there a relationship between temp range and temp? (yes)
summary(lm(annual_temp_range ~ avg_temp, data=ejectives))

library(car)
data.contrasts <- list(family_id = contr.sum, macroarea = contr.sum, elevation = contr.sum, avg_temp = contr.sum, annual_temp = contr.sum, avg_precipitation = contr.sum, avg_temp = contr.sum, annual_temp_range = contr.sum)
model1 <- lm(Ejectives ~ family_id + macroarea + elevation:family_id + elevation:macroarea + elevation * avg_temp + elevation * annual_temp_range + elevation * avg_precipitation + avg_precipitation * avg_temp + annual_temp_range * avg_precipitation + annual_temp_range * avg_temp, data=ejectives)
model2 <- lm(Ratios ~ family_id + macroarea + elevation:family_id + elevation:macroarea + elevation * avg_temp + elevation * annual_temp_range + elevation * avg_precipitation + avg_precipitation * avg_temp + annual_temp_range * avg_precipitation + annual_temp_range * avg_temp, data=ejectives)
model3 <- lm(has_ejectives ~ family_id + macroarea + elevation:family_id + elevation:macroarea + elevation * avg_temp + elevation * annual_temp_range + elevation * avg_precipitation + avg_precipitation * avg_temp + annual_temp_range * avg_precipitation + annual_temp_range * avg_temp, data=ejectives)

ancova1 <- Anova(model1, contrasts=data.contrasts, type=3, singular.ok=TRUE)
ancova2 <- Anova(model2, contrasts=data.contrasts, type=3, singular.ok=TRUE)
ancova3 <- Anova(model3, contrasts=data.contrasts, type=3, singular.ok=TRUE)

ancova1
ancova2
ancova3

# Plots
library(ggplot2)
library(ggpubr)
ggtheme <- theme(
  line = element_line(colour="#ad000e", size=0.8),
  plot.background = element_rect(fill="#ffffff"),    # Background of the entire plot
  panel.border = element_rect(colour="#ffffff", fill=NA, linewidth = 0.6),
  panel.background = element_rect(colour="#ffffff", fill="#ffffff"),
  panel.grid.major.y = element_line(linewidth=0),
  panel.grid.major.x = element_line(linewidth=0),
  panel.grid.minor.x = element_line(linewidth=0),
  panel.grid.minor.y = element_line(linewidth=0),
  axis.line = element_line(linewidth = 1, colour = "#000000"),
  axis.ticks= element_blank(),
  axis.text = element_text(family="Cantarell", colour="#000000", size = 16),
  axis.title = element_text(family="Cantarell", colour="#000000", size = 18),
  axis.title.y = element_text(margin=unit(c(0.6,0.6,0.6,0.6), "cm")),
  axis.title.x = element_text(margin=unit(c(0.6,0.6,0.6,0.6), "cm")),
  legend.position = "none",
  plot.margin = unit(c(0.5,0.5,0.5,0.5), "cm")
)

dichotomy_elev_plot <- ggplot(ejectives, aes(x=has_ejectives, y=elevation, fill=has_ejectives)) + geom_boxplot(outlier.size = 2) + 
  ggtheme + labs(y="Elevation (m)", x="") + scale_x_discrete(labels=c("Lacks ejectives", "Has ejectives"))
dichotomy_temp_plot <- ggplot(ejectives, aes(x=has_ejectives, y=avg_temp, fill=has_ejectives)) + geom_boxplot(outlier.size = 2) +
  ggtheme + labs(y="Temperature (°C)", x="") + scale_x_discrete(labels=c("Lacks ejectives", "Has ejectives"))
dichotomy_range_plot <- ggplot(ejectives, aes(x=has_ejectives, y=annual_temp_range, fill=has_ejectives)) + geom_boxplot(outlier.size = 2) + 
  ggtheme + labs(y="Temperature range (°C)", x="") + scale_x_discrete(labels=c("Lacks ejectives", "Has ejectives"))
dichotomy_precip_plot <- ggplot(ejectives, aes(x=has_ejectives, y=avg_precipitation, fill=has_ejectives)) + geom_boxplot(outlier.size = 2) +
  ggtheme + labs(y="Precipitation (mm)", x="") + scale_x_discrete(labels=c("Lacks ejectives", "Has ejectives"))

boxplots <- ggarrange(dichotomy_elev_plot, dichotomy_temp_plot, dichotomy_range_plot, dichotomy_precip_plot,
                    labels = c("a", "b", "c", "d"),
                    ncol = 2, nrow = 2,
                    font.label = list(size = 24, family="Cantarell"))

png(filename="plots/boxplots.png", width=1024, height=1024)
print(boxplots)
dev.off()

elev_temp_plot_both <- ggplot(ejectives, aes(x=elevation, y=avg_temp, color=family_id)) + geom_point(size=2, aes(shape=has_ejectives)) + scale_shape_manual(values=c(1, 19)) + 
  ggtheme + labs(x="Elevation (m)", y="Temperature (°C)")
elev_range_plot_both <- ggplot(ejectives, aes(x=elevation, y=annual_temp_range, color=family_id)) + geom_point(size=2, aes(shape=has_ejectives)) + scale_shape_manual(values=c(1, 19)) + 
  ggtheme + labs(x="Elevation (m)", y="Temperature range (°C)")
elev_precip_plot_both <- ggplot(ejectives, aes(x=elevation, y=avg_precipitation, color=family_id)) + geom_point(size=2, aes(shape=has_ejectives)) + scale_shape_manual(values=c(1, 19)) + 
  ggtheme + labs(x="Elevation (m)", y="Precipitation (mm)")
elev_temp_plot_ejectives <- ggplot(yes_ejectives, aes(x=elevation, y=avg_temp, color=family_id)) + geom_point(size=2, shape=19) + 
  ggtheme + labs(x="Elevation (m)", y="Temperature (°C)")
elev_range_plot_ejectives <- ggplot(yes_ejectives, aes(x=elevation, y=annual_temp_range, color=family_id)) + geom_point(size=2, shape=19) + 
  ggtheme + labs(x="Elevation (m)", y="Temperature range (°C)")
elev_precip_plot_ejectives <- ggplot(yes_ejectives, aes(x=elevation, y=avg_precipitation, color=family_id)) + geom_point(size=2, shape=19) + 
  ggtheme + labs(x="Elevation (m)", y="Precipitation (mm)")
elev_temp_plot_no_ejectives <- ggplot(no_ejectives, aes(x=elevation, y=avg_temp, color=family_id)) + geom_point(size=2, shape=1) + 
  ggtheme + labs(x="Elevation (m)", y="Temperature (°C)")
elev_range_plot_no_ejectives <- ggplot(no_ejectives, aes(x=elevation, y=annual_temp_range, color=family_id)) + geom_point(size=2, shape=1) + 
  ggtheme + labs(x="Elevation (m)", y="Temperature range (°C)")
elev_precip_plot_no_ejectives <- ggplot(no_ejectives, aes(x=elevation, y=avg_precipitation, color=family_id)) + geom_point(size=2, shape=1) + 
  ggtheme + labs(x="Elevation (m)", y="Precipitation (mm)")

scatters <- ggarrange(elev_temp_plot_both, elev_range_plot_both, elev_precip_plot_both, elev_temp_plot_ejectives, elev_range_plot_ejectives, elev_precip_plot_ejectives, elev_temp_plot_no_ejectives, elev_range_plot_no_ejectives, elev_precip_plot_no_ejectives,
                      labels = c("a", "b", "c", "d", "e", "f", "g", "h", "i"),
                      ncol = 3, nrow = 3,
                      font.label = list(size = 24, family="Cantarell"))

png(filename="plots/scatters.png", width=1536, height=1536)
print(scatters)
dev.off()
