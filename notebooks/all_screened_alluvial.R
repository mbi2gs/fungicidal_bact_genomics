library(tidyverse)
library(ggalluvial)


colormap = c('Actinobacteriota'='#de8735',
             'Firmicutes'='#5d7c61',
             'Firmicutes_I'='#4886af',
             'Proteobacteria'='#dc523f',
             'Bacteroidota'='#92a488')

actmap = c('FALSE' = 'Inactive', 'TRUE' = "Active")

df = read_delim('data/isolates.tsv', delim='\t') %>%
  mutate(sample_type_lump = fct_lump_min(sample_type, 50)) %>%
  select(strain_id, sample_type_lump, country, phylum, sa_confirmed_activity, bs_confirmed_activity) %>%
  mutate(activity = actmap[as.character((sa_confirmed_activity + bs_confirmed_activity) > 0)]) %>%
  group_by(sample_type_lump, country, phylum, activity) %>%
  summarise(n = n())
df$activity = as.factor(df$activity)

ggplot(df,
       aes(y = n, 
           axis1=country,
           axis2=sample_type_lump, 
           axis3=phylum, 
           axis4=activity)) +
  geom_flow(alpha=0.75, aes(fill=phylum)) +
  scale_fill_manual(values = colormap) +
  geom_stratum(alpha = 1, 
               fill="lightgray",
               color="white",
               size=1,
               width=0.35) +
  geom_text(stat = "stratum",
            size=3.5,
            aes(label = after_stat(stratum))) +
  labs(y="Number of isolates") +
  theme_minimal() +
  theme(legend.position = "none",
        axis.text.x = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank())

ggsave('images/all_screened_alluvial.png', width=7, height=5, dpi=300)
