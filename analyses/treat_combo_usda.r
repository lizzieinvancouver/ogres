# started Jul 8, 2024 by Fredi

# aim is read in the csv files from everyone's data that will include both sourced cleaning code and write out a raw file

# housekeeping
rm(list=ls()) 
options(stringsAsFactors = FALSE)

if(length(grep("deirdreloughnan", getwd()) > 0)) {
  setwd("~/Documents/github/egret/analyses")
} else if(length(grep("christophe_rouleau-desrochers", getwd())) > 0){
  setwd("/Users/christophe_rouleau-desrochers/Documents/github/egret/analyses")
} else if(length(grep("frederik", getwd())) > 0){
  setwd("/Users/frederik/github/egret/analyses")
}

egret <- read.csv("./output/egretclean.csv", sep=",", header=TRUE)


unique(egret$woody)
unique(as.character(egret$woody))
#
names(egret)

#### explore storage types and how many spp per storage temp and duration
sppwith_storagetime <- egret$latbi[which(!is.na(egret$storage.time))]
unique(sppwith_storagetime) #these spp have a storage time

sppwith_storagetemp <- egret$latbi[which(!is.na(egret$storage.temp))]
unique(sppwith_storagetemp) #these spp have a storage temp

sppwith_both <- sppwith_storagetime[which(sppwith_storagetime %in% sppwith_storagetemp)]
unique(sppwith_both) #these spp have both storage time and temp -> great 149 species have that criteria

#how many "latid" do we have in each level of "storage_Type"
tapply(egret$latbi, egret$storageType, function(x) length(unique(x)))
tapply(egret$datasetIDstudy, egret$storageType, function(x) length(unique(x)))

tmp_spp <- aggregate(latbi ~ storageType, data = egret, FUN = function(x) length(unique(x)))
tmp_stud <- aggregate(datasetIDstudy ~ storageType, data = egret, FUN = function(x) length(unique(x)))

#aggregate(latbi ~ scarifTypeGen, data = egret, FUN = function(x) length(unique(x)))
#aggregate(datasetIDstudy ~ scarifTypeGen, data = egret, FUN = function(x) length(unique(x)))


ggplot(tmp_spp, aes(x = storageType, y = latbi, fill = storageType)) +
    geom_bar(stat = "identity", position = "dodge")

egret$scarifTypeGen

unique(egret$latbi)

length(unique(egret$spec))


unique(egret$photoperiod)


#these are the most cleaned variables:
egret$chill.tempCor
egret$germ.tempCor
str(egret)

#how many species are in each datasetID
datasetID <- aggregate(species ~ datasetID, data = egret, FUN = function(x) length(unique(x)))


#################################################################################
#################################################################################
usda <- read.csv("./scrapeUSDAseedmanual/output/usdaGerminationData.csv", sep=",", header=TRUE)

#
###add stratification and chilling
usda$chilling<-ifelse(!is.na(usda$cold.strat.dur.Avg),"Y",usda$chilling)
usda$chilling<-ifelse(!is.na(usda$cold.strat.dur.Max),"Y",usda$chilling)
usda$chilling<-ifelse(!is.na(usda$cold.strat.dur.Min),"Y",usda$chilling)


###add stratification to chilling values
usda$chill.dur.Min<-ifelse(!is.na(usda$cold.strat.dur.Min),usda$cold.strat.dur.Min,usda$chill.dur.Min)
usda$chill.dur.Max<-ifelse(!is.na(usda$cold.strat.dur.Max),usda$cold.strat.dur.Max,usda$chill.dur.Max)
usda$chill.dur.Avg<-ifelse(!is.na(usda$cold.strat.dur.Avg),usda$cold.strat.dur.Avg,usda$chill.dur.Avg)
usda$chill.duraton<-ifelse(!is.na(usda$cold.stratification.duration),usda$cold.stratification.duration,usda$chill.duraton)

#
usda$responseVarClean <- usda$responseVar
#these columns show probably the same type of percentage, so rename them to "perc.standard"
usda$responseVar_clean[usda$responseVar_clean == "percent.germ"] <- "perc.standard"
usda$responseVar_clean[usda$responseVar_clean == "percent.germ.total"] <- "perc.standard"
usda$responseVar_clean[usda$responseVar_clean == "germ.capacity"] <- "perc.standard"
usda$responseVar_clean[usda$responseVar_clean == "mean.germ.capacity"] <- "perc.standard"
usda$responseVar_clean[usda$responseVar_clean == "percent.germ.15degC.incubated"] <- "perc.standard"
#another two that are probably the same
usda$responseVar_clean[usda$responseVar_clean == "mean.percent.germ.energy"] <- "percent.germ.energy"

#make a new column "spec" to combine genus and species
usda$latbi <- paste(usda$genus, usda$species, sep = "_")

#these are the interesting exploratory variables
##forcing
##chilling
##scarification

##create indicator variables
usda$forc_indic <- "no"
usda$chill_indic <- "no"
usda$scar_indic <- "no"

#####forcing
##what are variables related to forcing
unique(usda$germ.dur.Min)
unique(usda$germ.dur.Max)
unique(usda$germ.duration)
#check them
#if row contains a value then put "yes" in usda$forc_indic
usda$forc_indic[!is.na(usda$germ.dur.Min)] <- "yes"
usda$forc_indic[!is.na(usda$germ.dur.Max)] <- "yes"
usda$forc_indic[!is.na(usda$germ.duration)] <- "yes"


#####chilling
##what are variables related to chilling
unique(usda$stratification.temp)
unique(usda$cold.stratification.duration)
unique(usda$chilling) #
unique(usda$chill.duraton)
unique(usda$cold.strat.dur.Min)
unique(usda$cold.strat.dur.Max)
unique(usda$cold.strat.dur.Avg)
unique(usda$chill.dur.Avg)

#check them
#if row contains a value then put "yes" in usda$forc_indic
#usda$chill_indic[!is.na(usda$stratification.temp)] <- "yes"
#usda$chill_indic[!is.na(usda$cold.stratification.duration)] <- "yes"
usda$chill_indic[usda$chilling == "Y"] <- "yes" #if "chilling" contains "Y" then put "yes" in usda$chill_indication
#usda$chill_indic[!is.na(usda$chill.duraton)] <- "yes"
#usda$chill_indic[!is.na(usda$cold.strat.dur.Min)] <- "yes"
#usda$chill_indic[!is.na(usda$cold.strat.dur.Max)] <- "yes"
#usda$chill_indic[!is.na(usda$cold.strat.dur.Avg)] <- "yes"
#usda$chill_indic[!is.na(usda$chill.dur.Avg)] <- "yes"


#####scarification
##what are variables related to scarification
unique(usda$scarifTypeGen)
unique(usda$scarifType)
#check them
#if row contains a value then put "yes" in usda$forc_indic
usda$scar_indic[!is.na(usda$scarifTypeGen)] <- "yes"



### calculate treatment combinations
#how many species were exposed to forcing only
#how many rows are there with "forc_indic" == "yes"
length(usda$forc_indic[usda$forc_indic == "yes"]) 
#how many unique species with "forc_indic" == "yes"
length(unique(usda$spec[usda$forc_indic == "yes"])) #270 species

# Save each value for every combination
combination_table <- data.frame(forc_indic = c("yes", "yes", "yes", "yes", "no", "no", "no", "no"),
                                chill_indic = c("yes", "yes", "no", "no", "yes", "yes", "no", "no"),
                                scar_indic = c("yes", "no", "yes", "no", "yes", "no", "yes", "no"),
                                number = c(length(unique(usda$spec[usda$forc_indic == "yes" & usda$chill_indic == "yes" & usda$scar_indic == "yes"])),
                                           length(unique(usda$spec[usda$forc_indic == "yes" & usda$chill_indic == "yes" & usda$scar_indic == "no"])),
                                           length(unique(usda$spec[usda$forc_indic == "yes" & usda$chill_indic == "no" & usda$scar_indic == "yes"])),
                                           length(unique(usda$spec[usda$forc_indic == "yes" & usda$chill_indic == "no" & usda$scar_indic == "no"])),
                                           length(unique(usda$spec[usda$forc_indic == "no" & usda$chill_indic == "yes" & usda$scar_indic == "yes"])),
                                           length(unique(usda$spec[usda$forc_indic == "no" & usda$chill_indic == "yes" & usda$scar_indic == "no"])),
                                           length(unique(usda$spec[usda$forc_indic == "no" & usda$chill_indic == "no" & usda$scar_indic == "yes"])),
                                           length(unique(usda$spec[usda$forc_indic == "no" & usda$chill_indic == "no" & usda$scar_indic == "no"]))))

combination_table



##################################################################
#### make additional rows for every min/max pair, eg. chilling that has a minimum and maximum value lead to a min and maximum percentage outcaome 
# identify the columns with min max
#identify any colums with "Min" or "Max" in the name
mincols <- grep("Min", names(usda), value = TRUE)
maxcols <- grep("Max", names(usda), value = TRUE)


############ NEW approach

#how does the table look like?
head(usda)
names(usda)
#how many species do we have with values in 
tapply(usda$spec, usda$chill.dur.Max, function(x) length(unique(x)))
tapply(usda$spec, usda$chill.dur.Max, function(x) (unique(x)))

aggregate(spec ~ chill.dur.Max, data = usda, FUN = function(x) length(unique(x)))

length(unique(usda[!is.na(usda$chill.dur.Max), "spec"])) #57 spp have a value in chill.dur.Max



# Step 1: Filter rows with non-NA values in all specified columns using basic R functions
filtered_rows <- usda[!is.na(usda$chill.dur.Min) & !is.na(usda$chill.dur.Max) & 
                      !is.na(usda$responseValueMin) & !is.na(usda$responseValueMax), ]

filtered_spp <- usda[!is.na(usda$chill.dur.Min) & !is.na(usda$chill.dur.Max) & 
                      !is.na(usda$responseValueMin) & !is.na(usda$responseValueMax), "spec"]

tmp_X <- filtered_rows$X
spec_X <- filtered_rows$spec

# Remove all rows filtered rows from the original data frame
usda_new <- usda[!usda$X %in% tmp_X, ]
#check
length(usda_new$X) + length(tmp_X)
length(usda$X)

#create new dataframe for chill.dur.Min and responseValueMin
df_min <- filtered_rows
#assign "NA" to all rows of column "chill.dur.Max" and "responseValueMax"
df_min$chill.dur.Max <- NA
df_min$responseValueMax <- NA
#moving the values from "chill.dur.Min" to "chill.dur"
df_min$chill.duraton <- df_min$responseValueMin
#moving the values from "responseValueMin" to "responseValue"
df_min$responseValue <- df_min$responseValueMin


#create new dataframe for chill.dur.Max and responseValueMax
df_max <- filtered_rows
#assign "NA" to all rows of column "chill.dur.Max" and "responseValueMax"
df_max$chill.dur.Min <- NA
df_max$responseValueMin <- NA
#moving the values from "chill.dur.Max" to "chill.dur"
df_max$chill.duraton <- df_max$responseValueMax
#moving the values from "responseValueMax" to "responseValue"
df_max$responseValue <- df_max$responseValueMax


#add the new dataframes "df_min" and "df_max" to the "usda_new" dataframe
usda_new <- rbind(usda_new, df_min)
usda_new <- rbind(usda_new, df_max)

#check
length(usda_new$X) - (length(tmp_X))
length(usda$X)

#some more checks

#extract species that have min/max values for chill duration and a corresponding min/max value in the response variable
chilldurminnonNA <- usda$spec[which(!is.na(usda$chill.dur.Min))]
chilldurmaxonNA <- usda$spec[which(!is.na(usda$chill.dur.Max))]
respvarminnoNA <- usda$spec[which(!is.na(usda$responseValueMin))]
respvarmaxnoNA <- usda$spec[which(!is.na(usda$responseValueMax))]

sppwithminmaxchill <- chilldurminnonNA[which(chilldurminnonNA %in% chilldurmaxonNA)]

sppwithminmaxresp <- respvarminnoNA[which(respvarminnoNA %in% respvarmaxnoNA)]

sppwithcillresp <- sppwithminmaxchill[which(sppwithminmaxchill %in% sppwithminmaxresp)]

spp_split<-unique(sppwithcillresp) #20 species have this combination and we can split them up

########## this option is no longer needed and limited but keep it for now
#dublicate dataframe "usda" with rows containing a level in "spp_split" within usda$spec
newmin <- usda[usda$spec %in% spp_split,]
#assign "NA" to all rows of column "chill.dur.Max" and "responseValueMax"
newmin$chill.dur.Max <- NA
newmin$responseValueMax <- NA

#dublicate dataframe "usda" with rows containing a level in "spp_split" within usda$spec
newmax <- usda[usda$spec %in% spp_split,]
#assign "NA" to all rows of column "chill.dur.Max" and "responseValueMax"
newmax$chill.dur.Min <- NA
newmax$responseValueMin <- NA

str(newmax)
newmax[,"spec"]
## make a new dataframe: 
# remove all rows from the "usda" containing a level in "spp_split" within usda$spec
usda_new<-usda[!usda$spec %in% spp_split,]

#add the new dataframes "newmin" and "newmax" to the "usda" dataframe
usda_new <- rbind(usda_new, newmin)
usda_new <- rbind(usda_new, newmax)

#add back rows of these species that didn't contain anything in "chill.dur.Min" and "chill.dur.Max".
unique(usda_new[usda_new$spec,"spec"])
#add rows of these species that didn't contain anything in "responseValueMin" and "responseValueMax".

#check
# Is the number of rows in the new dataframe "usda_new" larger by 20 to the number of rows in the old dataframe "usda"?
nrow(usda_new) == nrow(usda) + 20




### 
#search for latbi containing "Fagus"
unique(egret$latbi[grepl("Fagus", egret$latbi)])
egret[egret$latbi=="Fagus_sylvatica","latbi"]

#how many studies report on Fagus sylvatica
unique(egret[egret$latbi=="Fagus_sylvatica","datasetIDstudy"]) 2 studies





# same for dataset usda
unique(usda$latbi[grepl("Fagus", usda$latbi)])


names(usda)
usda$seed.type
summary(usda)
usda$pretreatmentFeces

###in usda
unique(usda$pretreatmentFeces)
unique(usda$other.treatment[grepl("fece", egret$other.treatment)])

###in egret
#does "fece" appear in these columns in egret?
unique(egret$chemicalCor)
unique(egret$other.treatment[grepl("fece", egret$other.treatment)])
unique(egret$scarifTypeSpe[grepl("fece", egret$scarifTypeSpe)])
unique(egret$scarifTypeGen[grepl("fece", egret$scarifTypeGen)])
unique(egret$scarifType[grepl("fece", egret$scarifType)])
unique(egret$scarif.type[grepl("fece", egret$scarif.type)])
unique(egret$treatment[grepl("fece", egret$treatment)])
unique(egret$scarifType[grepl("fece", egret$scarifType)])

#any column containing "fece" in egret?
unique(usda[, grepl("Fece", colnames(usda))])
unique(egret[, grepl("Fece", colnames(egret))])
