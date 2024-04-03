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
# use the script called 'contingency beh study 01 clean data.R"
# or saved data
#data.long <- read.csv(data contingency beh study pilot clean long data.csv")

#topic
data.long$topic <- as.factor(data.long$topic)
#data.long$order <- as.factor(data.long$order) # GC: to nie powinien być factor
data.long <- data.long %>% 
  mutate(topic = factor(topic, levels = c("hom", "clim", "gmo")))
levels(data.long$topic)

#---- Effects of task difficulty (no concordance) ----
m0.1 <- lmer(data = data.long,
             #data = data.long, # %>% filter(ideology != 4), # remove people with ideology = 4
             #data = data.long %>% filter(prior.conc != 0), 
           resp ~ condition + 
             order + topic + (1|subj.id)) 
summary(m0.1)

# add numeracy
m0.2 <- lmer(data = data.long,
             #data = data.long, # %>% filter(ideology != 4), # remove people with ideology = 4
             #data = data.long %>% filter(prior.conc != 0), 
             resp ~ condition * num_c + 
               order + topic + (1|subj.id)) 
summary(m0.2)

#---- #Q1.1. Are people less accurate when conclusions are discordant with their ideology or priors? ---- 
#---- Concordance with ideology ----
#Ideology: self-identification in terms of cultural ideology (progressive vs. conservative)
m0.q1.1.ideology <- lmer(data = data.long %>% filter(ideology != 4), # remove people with ideology = 4
                         resp ~ 1 + (1|subj.id)) 
summary(m0.q1.1.ideology)
VarCorr(m0.q1.1.ideology) %>% 
  as_tibble() %>%
  mutate(icc=vcov/sum(vcov)) %>%
  dplyr::select(grp, icc)

#add ideology concordance
# GC: jak modele się nie wyliczą to możemy spróbować osobno je dać albo opuścić topic
m1.q1.1.ideology <- lmer(data = data.long %>% filter(ideology != 4),
                         resp ~ ideology.conc + 
                           topic + order +
                           (1|subj.id))
summary(m1.q1.1.ideology)
anova(m1.q1.1.ideology) #ideology.conc neutr sig.

#Q1.2. Are people more accurate when high (vs. low) on cognitive sophistication?
m2.q1.2.ideology <- lmer(data = data.long %>% filter(ideology != 4), 
                         resp ~ num_c + 
                           topic + order + (1|subj.id))
summary(m2.q1.2.ideology)
anova(m2.q1.2.ideology)
m2.q1.2.ideology %>% ggemmeans(terms = "num_c") %>% plot()
#m2.q1.2.ideology %>% ggemmeans(terms = "topic") %>% plot()
#m2.q1.2.ideology %>% ggemmeans(terms = c("num_c", "topic")) %>% plot()

# Q1.3. What are the interactive effects of ideology and cognitive sophistication on accuracy?
m3.q1.3.ideology <-lmer(data = data.long %>% filter(ideology != 4), 
                        resp ~ ideology.conc * num_c +
                          topic + order + (1|subj.id))
summary(m3.q1.3.ideology)
anova(m3.q1.3.ideology)
#m3.q1.3.ideology  %>% ggemmeans(terms = c("num_c", "ideology.conc")) %>% plot()

#Q1.4. Are these effects further moderated by task difficulty?
#ideology +  difficulty interaction 
m4.q1.4.ideology <-lmer(data = data.long %>% filter(ideology != 4),
                        resp ~ ideology.conc * num_c * condition + 
                          topic + order + (1|subj.id))
#fixed-effect model matrix is rank deficient so dropping 1 column / coefficient
summary(m4.q1.4.ideology) #ideology.conc and interaction sig
anova(m4.q1.4.ideology)
#m4.q1.4.ideology %>% ggemmeans(terms = c("num_c", "ideology.conc", "condition")) %>% 
#  plot()

# +topic interaction
m5.q1.5.ideology <-lmer(data = data.long %>% filter(ideology != 4),
                        resp ~ ideology.conc * num_c * condition * topic + 
                          order + (1|subj.id))
#fixed-effect model matrix is rank deficient so dropping 5 columns / coefficients
summary(m5.q1.5.ideology)
anova(m5.q1.5.ideology) #topic gmo, ideology.concneutr and int. sig

#polit cult +  difficulty interaction
# GC: tu nie wiem co jest dodawane w tym modelu? To nie jest to samo co w modelu 
# m4.q1.4.ideology
m1.q1.6 <-lmer(data = data.long %>% filter(ideology != 4),
               resp ~ ideology.conc * num_c * condition + 
                 topic + order + (1|subj.id))
#fixed-effect model matrix is rank deficient so dropping 1 column / coefficient
summary(m1.q1.6)
anova(m1.q1.6)

#polit cult +  difficulty interaction + topic interaction
# GC: j.w. - co tu jest nowego?
m1.q1.7 <-lmer(data = data.long %>% filter(ideology != 4), 
               resp ~ ideology.conc * num_c * condition * topic + 
                 order + (1|subj.id))
#fixed-effect model matrix is rank deficient so dropping 5 columns / coefficients
summary(m1.q1.7)
anova(m1.q1.7)

#---- Concordance with prior position ----
# null model
m0.q1.1.prior <- lmer(data = data.long %>% filter(prior.conc != "neutr"),
                      resp ~ 1 + (1|subj.id))
summary(m0.q1.1.prior)
VarCorr(m0.q1.1.prior) %>%
  as_tibble() %>%
  mutate(icc = vcov / sum(vcov)) %>%
  dplyr::select(grp, icc)

# add concordance with priors
m1.q1.1.prior <- lmer(data = data.long %>% filter(prior.conc != "neutr"),
       resp ~ 1 + prior.conc + 
         topic + order + (1|subj.id)) 
summary(m1.q1.1.prior)
anova(m1.q1.1.prior)

#Q1.2. Are people more accurate when high (vs. low) on cognitive sophistication?
# add numeracy
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
m3.q1.3.prior  %>% ggemmeans(terms = c("num_c", "prior.conc")) %>% plot()
#przy niezgodnych tym lepsze odp, im lepsze num, bez znaczenia dla zgodnych

#Q1.4. Are these effects further moderated by task difficulty?
#prior +  difficulty interaction
m4.q1.4.prior <- lmer(data = data.long %>% filter(prior.conc != "neutr"),
                      resp ~ prior.conc * num_c * condition.binary +
                        topic + order + (1|subj.id)) 
summary(m4.q1.4.prior)
anova(m4.q1.4.prior)
m4.q1.4.prior %>% ggemmeans(terms = c("num_c", "prior.conc", "condition.binary")) %>% plot()

#+topic interaction (ten model do zastanowienia)
m5.q1.5.prior <- lmer(data = data.long %>% filter(prior.conc != "neutr"),
                     resp ~ prior.conc * num_c * condition.binary * topic +
                       order + (1 | subj.id)) #tu nie ma komunitaktu ostrzegawczego w końcu
summary(m5.q1.5.prior)
anova(m5.q1.5.prior) #topic istotny i int 4 st. istotna
#m5.q1.5.prior %>% ggemmeans(terms = c("prior.cult"+"num_c"+"contition.binary"+"topic")) %>% plot()







