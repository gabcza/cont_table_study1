#---- Info -----
# Goal: analyze data from contingency beh study 1
# Q1. What is the accuracy of responding in the contingency table task?
#
# write 07-03-2024 by Iwona
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
#data.long <- read.csv("data contingency beh study clean long data.csv")

#topic
data.long$topic <- as.factor(data.long$topic)
#data.long$order <- as.factor(data.long$order) # GC: to nie powinien być factor
data.long <- data.long %>% 
  mutate(topic = factor(topic, levels = c("hom", "clim", "gmo")))
levels(data.long$topic)

# check means for priors 
means <- data.long %>% 
  group_by(subj.id, topic, condition) %>% slice(1) %>% ungroup() %>%
  #group_by(topic, condition) %>% 
  summarize(m.clim.pos = mean(prior.climate.pos),
            m.gmo.pos = mean(prior.gmo.pos),
            m.hom.pos = mean(prior.hom.pos),
            m.clim.cert = mean(prior.climate.cert),
            m.gmo.cert = mean(prior.gmo.cert),
            m.hom.cert = mean(prior.hom.cert),
            m.clim.imp = mean(prior.climate.imp),
            m.gmo.imp = mean(prior.gmo.imp),
            m.hom.imp = mean(prior.hom.imp),
            #m.clim.diff = mean(prior.climate.diff),
            #m.gmo.diff = mean(prior.gmo.diff),
            #m.hom.diff = mean(prior.hom.diff)
            ) %>%
  gather("var", "value") %>%
  separate(var, into = c("m", "topic", "question")) %>%
  mutate(question = factor(question, levels = c("pos", "cert", "imp")))
  #spread(question, value) %>%
  #select(topic, pos, cert, imp, diff)
means
means %>% ggplot(aes(topic, value, fill = topic)) + 
  geom_bar(stat = "identity", position = "dodge") +
  facet_wrap(~question) + 
  theme_classic()

#---- Q1.2: Are people more accurate given task difficulty and numeracy skills?   ----
m0.q1.1 <- lmer(data = data.long,
             #data = data.long, # %>% filter(ideology != 4), # remove people with ideology = 4
             #data = data.long %>% filter(prior.conc != 0), 
           resp ~ condition.binary +
             order + topic + (1|subj.id)) 
summary(m0.q1.1)
m0.q1.1 %>% ggemmeans(c("condition.binary")) %>% plot() +
  labs(title = "", y = "Accuracy", color = "Difficulty")

# check differences between the conditions
m0.q1.2 <- lmer(data = data.long,
                #data = data.long, # %>% filter(ideology != 4), # remove people with ideology = 4
                #data = data.long %>% filter(prior.conc != 0), 
                resp ~ condition.binary * topic +
                  order + (1|subj.id)) 
summary(m0.q1.2)
m0.q1.2 %>% ggemmeans(c("topic", "condition.binary")) %>% plot() +
  labs(title = "", y = "Accuracy", color = "Difficulty")

# add numeracy
m0.q1.3 <- lmer(data = data.long,
                #data = data.long, # %>% filter(ideology != 4), # remove people with ideology = 4
                #data = data.long %>% filter(prior.conc != 0), 
                resp ~ condition.binary * num_c + 
                  order + topic + (1|subj.id)) 
summary(m0.q1.3)
anova(m0.q1.3)
m0.q1.3 %>% ggemmeans(c("num_c", "condition.binary")) %>% plot() +
  labs(title = "", y = "Accuracy", x = "Numeracy", color = "Difficulty")

# add numeracy and topic interaction
m0.q1.4 <- lmer(data = data.long,
                #data = data.long, # %>% filter(ideology != 4), # remove people with ideology = 4
                #data = data.long %>% filter(prior.conc != 0), 
                resp ~ condition.binary * num_c * topic + 
                  order + (1|subj.id)) 
summary(m0.q1.4)
anova(m0.q1.4)
m0.q1.4 %>% ggemmeans(c("num_c", "condition.binary", "topic")) %>% plot() +
  labs(title = "Accuracy", y = "Accuracy", x = "Numeracy", color = "Difficulty")
  
# separate models per topic
# climate
m0.q1.4.clim <- lm(data = data.long %>% filter(topic == "clim"),
                #data = data.long, # %>% filter(ideology != 4), # remove people with ideology = 4
                #data = data.long %>% filter(prior.conc != 0), 
                resp ~ condition.binary * num_c + order) 
summary(m0.q1.4.clim)
anova(m0.q1.4.clim)
m0.q1.4.clim %>% ggemmeans(c("num_c", "condition.binary")) %>% plot() +
  labs(title = "Accuracy", y = "Accuracy", x = "Numeracy", color = "Difficulty")
# gmo
m0.q1.4.gmo <- lm(data = data.long %>% filter(topic == "gmo"),
                   #data = data.long, # %>% filter(ideology != 4), # remove people with ideology = 4
                   #data = data.long %>% filter(prior.conc != 0), 
                   resp ~ condition.binary * num_c + order) 
summary(m0.q1.4.gmo)
m0.q1.4.gmo %>% ggemmeans(c("num_c", "condition.binary")) %>% plot() +
  labs(title = "Accuracy", y = "Accuracy", x = "Numeracy", color = "Difficulty")
# homeopathy
m0.q1.4.hom <- lm(data = data.long %>% filter(topic == "hom"),
                  #data = data.long, # %>% filter(ideology != 4), # remove people with ideology = 4
                  #data = data.long %>% filter(prior.conc != 0), 
                  resp ~ condition.binary * num_c + order) 
summary(m0.q1.4.hom)
m0.q1.4.hom %>% ggemmeans(c("num_c", "condition.binary")) %>% plot() +
  labs(title = "Accuracy", y = "Accuracy", x = "Numeracy", color = "Difficulty")

# check numeracy per condition
data.long %>% group_by(condition, topic, prior.conc) %>%
  summarize(mean = mean(num_c, na.rm = T), sd = sd(num_c, na.rm = T),)

#---- Q1.1. Are people less accurate when conclusions are discordant with their ideology or priors? ---- 
#---- Concordance with ideology ----
#Ideology: self-identification in terms of cultural ideology (progressive vs. conservative)
m0.q1.1.ideology <- lmer(data = data.long %>% filter(ideology != 4), # remove people with ideology = 4
                         resp ~ 1 + (1|subj.id)) 
summary(m0.q1.1.ideology)
VarCorr(m0.q1.1.ideology) %>% 
  as_tibble() %>%
  mutate(icc=vcov/sum(vcov)) %>%
  dplyr::select(grp, icc) #0.1 due to subj

#add ideology concordance
# GC: jak modele się nie wyliczą to możemy spróbować osobno je dać albo opuścić topic
m1.q1.1.ideology <- lmer(data = data.long %>% filter(ideology != 4),# %>% filter(topic != "hom"),
                         resp ~ ideology.conc + 
                           #topic + 
                           order +
                           (1|subj.id))
summary(m1.q1.1.ideology)
anova(m1.q1.1.ideology) #

#Q1.2. Are people more accurate when high (vs. low) on cognitive sophistication?
# GC: nie wiem czy tak bym liczyła ten model (to samo co wyżej z wyłączeniem osób z id = 4)
# ale na razie zostawmy; możemy przesunąć te modele z Q1.2 wyżej (poza analizy concordance
# a ideologią albo priors)
m2.q1.2.ideology <- lmer(data = data.long %>% filter(ideology != 4), 
                         resp ~ num_c + 
                           topic + order + (1|subj.id))
summary(m2.q1.2.ideology)
anova(m2.q1.2.ideology)
m2.q1.2.ideology %>% ggemmeans(terms = "num_c") %>% plot()
m2.q1.2.ideology %>% ggemmeans(terms = "topic") %>% plot()
m2.q1.2.ideology %>% ggemmeans(terms = c("num_c", "topic")) %>% plot()

# Q1.3. What are the interactive effects of ideology and cognitive sophistication on accuracy?
m3.q1.3.ideology <-lmer(data = data.long %>% filter(ideology != 4), 
                        resp ~ ideology.conc * num_c +
                          topic + order + (1|subj.id))
summary(m3.q1.3.ideology)
anova(m3.q1.3.ideology)
m3.q1.3.ideology  %>% ggpredict(terms = c("num_c", "ideology.conc")) %>% plot() #not for continuous var
#fixed-effect model matrix is rank deficient so dropping 1 column / coefficient

#Q1.4. Are these effects further moderated by task difficulty?
#ideology +  difficulty interaction 
m4.q1.4.ideology <-lmer(data = data.long %>% filter(ideology != 4),
                        resp ~ ideology.conc * num_c * condition.binary + 
                          topic + order + (1|subj.id))
#fixed-effect model matrix is rank deficient so dropping 1 column / coefficient
summary(m4.q1.4.ideology) #ideology.conc and interaction sig
anova(m4.q1.4.ideology)
#m4.q1.4.ideology %>% ggemmeans(terms = c("num_c", "ideology.conc", "condition.binary")) %>% plot() #not for continuous var
pred.val.m4.q1.4.ideology <- ggpredict(m4.q1.4.ideology, terms = c("num_c", "ideology.conc", "condition.binary"))
plot(pred.val.m4.q1.4.ideology)

#---- Concordance with prior position ----
# null model
# To w sumie też jest mało informacyjne i docelowo bym usunęła
m0.q1.1.prior <- lmer(data = data.long %>% filter(prior.conc != "neutr"),
                      resp ~ 1 + (1|subj.id))
summary(m0.q1.1.prior)
VarCorr(m0.q1.1.prior) %>%
  as_tibble() %>%
  mutate(icc = vcov / sum(vcov)) %>%
  dplyr::select(grp, icc) #due to subj = .06

# add concordance with priors
m1.q1.1.prior <- lmer(data = data.long %>% filter(prior.conc != "neutr"),
       resp ~ 1 + prior.conc + 
         topic + order + (1|subj.id)) 
summary(m1.q1.1.prior)
anova(m1.q1.1.prior)
m1.q1.1.prior %>% ggemmeans(terms = "prior.conc") %>% 
  ggplot(aes(x, predicted, fill = x)) +
  geom_bar(stat = "identity") + 
  geom_errorbar(aes(ymin = conf.low, ymax = conf.high), width = 0.50) +
  labs(title = "",
       x = "Concordance with priors", y = "Accuracy", fill = "Concordance") + 
  #coord_cartesian(ylim = c(0,1)) +
  theme_minimal()
                                                          
#Q1.2. Are people more accurate when high (vs. low) on cognitive sophistication?
# add numeracy 
# GC: j.w. tego modelu raczej nie potrzebujemy
m2.q1.2.prior <- lmer(data = data.long %>% filter(prior.conc != "neutr"),
                      resp ~ 1 + num_c + 
                        topic + order + (1|subj.id)) 
summary(m2.q1.2.prior)
anova(m2.q1.2.prior)
m2.q1.2.prior %>% ggemmeans(terms = "num_c") %>% plot()

# Q1.3. What are the interactive effects of concordance with priors and cognitive sophistication on accuracy?
#topic & order as main effect
m3.q1.3.prior <- lmer(data = data.long %>% filter(prior.conc != "neutr"),
                      resp ~ prior.conc * num_c + 
                        topic + order + (1|subj.id)) 
summary(m3.q1.3.prior)
anova(m3.q1.3.prior)
m3.q1.3.prior  %>% ggemmeans(terms = c("num_c", "prior.conc")) %>% plot() +
  labs(title = "", x = "Concordance with priors", y = "Accuracy", 
       color = "Concordance") + 
  #coord_cartesian(ylim = c(0,1)) +
  theme_minimal()

#Q1.4. Are these effects further moderated by task difficulty?
#prior +  difficulty interaction
m4.q1.4.prior <- lmer(data = data.long %>% filter(prior.conc != "neutr"),
                      resp ~ prior.conc * num_c * condition.binary +
                        topic + order + (1|subj.id)) 
summary(m4.q1.4.prior)
anova(m4.q1.4.prior)
m4.q1.4.prior %>% ggemmeans(terms = c("num_c", "prior.conc", "condition.binary")) %>% 
  plot() + 
  labs(title = "", x = "Concordance with priors", y = "Accuracy", 
       color = "Concordance") #+ 
  #coord_cartesian(ylim = c(0,1)) +
  #theme_classic()

# add interaction with a topic (ten model do zastanowienia)
m5.q1.5.prior <- lmer(data = data.long %>% filter(prior.conc != "neutr"),
                     resp ~ prior.conc * num_c * condition.binary * topic +
                       order + (1 | subj.id))
summary(m5.q1.5.prior)
anova(m5.q1.5.prior) #
m5.q1.5.prior %>% 
  ggemmeans(terms = c("num_c", "prior.conc", "condition.binary", "topic")) %>% 
  plot() + 
  labs(title = "", x = "Concordance with priors", y = "Accuracy", 
       color = "Concordance") #+ 





