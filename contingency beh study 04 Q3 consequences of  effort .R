#---- Info -----
# Goal: analyze data from contingency beh study 1
#Q3. What are the consequences of investing effort for accuracy? 
#
# write 20-03-2024 by Iwona
#--------------------------------------------------------------------------------
#---- Load packages ----
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)
library(lme4)
library(lmerTest)
library(ggeffects)
options(scipen = 999)

#---- Load data in a long format ----
# use the script called '[main study] contingency beh study 01 clean data.R"
# or saved data
#data.long <- read.csv(data contingency beh study clean long data.csv")


#topic
data.long$topic <- as.factor(data.long$topic)
data.long <- data.long %>% 
  mutate(topic = factor(topic, levels = c("hom", "clim", "gmo")))
levels(data.long$topic)


# Remove responses below X seconds
x <- data.long %>% 
  filter(rt >= 20) 
nrow(x)
# >=10 seconds: 1362
# >=15 seconds: 1312
# >=20 seconds: 1256

# remove responses below 10 seconds
data.long <- data.long %>% filter(rt >= 10)


#---- Q3a. Does effort investment lead to more accurate responding? Does it depend on concordance?----
#---- Concordance with priors----
# main effect of effort on accuracy of responding
m1.q3.ef_acc.prior <- lmer(data = data.long %>% filter(prior.conc != "neutr"), 
                           resp ~ eff.index +
                           topic + order + (1|subj.id)) #boundary (singular) fit:
summary(m1.q3.ef_acc.prior)
anova(m1.q3.ef_acc.prior)
m1.q3.ef_acc.prior %>%
  ggemmeans(terms = "eff.index") %>%
  plot()

#add interaction with concordance
m2.q3.ef_acc.prior <- lmer(data = data.long %>% filter(prior.conc != "neutr"), 
                           resp ~ eff.index * prior.conc +
                             topic + order + (1|subj.id)) 
summary(m2.q3.ef_acc.prior)
anova(m2.q3.ef_acc.prior) 
m2.q3.ef_acc.prior  %>% ggemmeans(terms = c("eff.index", "prior.conc")) %>% plot()


#+difficulty
m3.q3.ef_acc.prior<- lmer(data = data.long %>% filter(prior.conc != "neutr"), 
                          resp ~ eff.index * prior.conc * condition.binary +
                            topic + order + (1|subj.id)) 
summary(m3.q3.ef_acc.prior)
anova(m3.q3.ef_acc.prior) 
m3.q3.ef_acc.prior  %>% ggemmeans(terms = c("eff.index", "prior.conc",  "condition.binary")) %>% plot()

#Q3b: Does the relationship between effort and accuracy depend on cognitive sophistication?
#Does increased effort investment among the sophisticated leads to more or less accurate 
#responding? Does it depend on concordance?
m4.q3.ef_acc.prior <- lmer(data = data.long %>% filter(prior.conc != "neutr"), 
                           resp ~ 1 +  eff.index + prior.conc + condition.binary + 
                           eff.index*prior.conc*condition.binary*num_c +
                           topic + order + (1|subj.id)) 
summary(m4.q3.ef_acc.prior)
anova(m4.q3.ef_acc.prior) #diff
#ggemmeans(m4.q3.ef_acc.prior, terms = c("eff.index", "num_c")) %>%
#  plot()

m4.q3.ef_acc.prior %>% ggemmeans(c("eff.index", "num_c[meansd]")) %>% plot() 

#---- Concordance with ideology----
m1.q3.ef_acc.ideology <- lmer(data = data.long %>% filter(ideology != 4), # GC: dodajemy filtrowanie ideology != 4 (?)
                              resp ~ 1 +  eff.index +
                              topic + order + (1|subj.id)) 
#boundary (singular) fit: see help('isSingular')
summary(m1.q3.ef_acc.ideology)
anova(m1.q3.ef_acc.ideology) 
m1.q3.ef_acc.ideology %>%
  ggemmeans(terms = "eff.index") %>%
  plot()

#add interaction
m2.q3.ef_acc.ideology <- lmer(data = data.long %>% filter(ideology != 4),
                              resp ~ eff.index * ideology.conc +
                              topic + order + (1|subj.id)) 

summary(m1.q3.ef_acc.ideology)
anova(m1.q3.ef_acc.ideology) 
m2.q3.ef_acc.ideology  %>% ggpredict(terms = c("eff.index", "ideology.conc")) %>% plot()

#+difficulty
m3.q3.ef_acc.ideology<- lmer(data = data.long %>% filter(ideology != 4), 
                             resp ~ eff.index * ideology.conc * condition.binary +
                               topic + order + (1|subj.id)) 
summary(m3.q3.ef_acc.ideology) 
anova(m3.q3.ef_acc.ideology) 
m3.q3.ef_acc.ideology  %>% ggpredict(terms = c("eff.index","ideology.conc", "condition.binary")) %>% plot()

#Q3b: Does the relationship between effort and accuracy depend on cognitive sophistication?
#Does increased effort investment among the sophisticated leads to more or less accurate 
#responding? Does it depend on concordance?
m4.q3.ef_acc.ideology <- lmer(data = data.long %>% filter(ideology != 4),
                              resp ~ eff.index * ideology.conc * condition.binary * num_c +
                              topic + order + (1|subj.id)) 

summary(m4.q3.ef_acc.ideology)
anova(m4.q3.ef_acc.ideology)
#ggemmeans(m4.q3.ef_acc.ideology, terms = c("eff.index", "num_c")) %>%
  #plot()
m4.q3.ef_acc.ideology %>% ggemmeans(c("eff.index", "num_c[meansd]")) %>% plot() 

ggpredict(m4.q3.ef_acc.ideology, terms = c("num_c", "ideology.conc")) %>%
  plot()

