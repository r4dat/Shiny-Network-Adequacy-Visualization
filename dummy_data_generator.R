## Generate random provider dataset.
library(zipcode)
set.seed=50
Facility_Types <- read.csv("Facility_Types.csv",stringsAsFactors=FALSE)
Provider_Types <- read.csv("Provider_Types.csv",stringsAsFactors=FALSE)


## Create underlying vectors to sample from.
prefixsam=c(NA)
firstsam = c("TRAISURE","TERALIN","GREG","CALLIS","DARELL","GEANA","EDWARD","PRESTON","RANDOLPH")
middlesam = c(NA)
lastsam = c("ABEURISHAL","ACEMAN","ACUNA-001","JOHNSON","ADAMSON","OBLAICH","BLAKE","BLAKELY")
suffixsam = c(NA)
physnonsam = c("Physician","Non-Physician")
streetsam = c("250 W 9TH ST")
networksam=c("NEN001","MIN003")
countysam = c ("countya","countyb")

## Concat facil and prov files.
colnames(Facility_Types)=c("type")
colnames(Provider_Types)=c("type")
tmp=as.vector(rbind(Facility_Types,Provider_Types))

npi = as.integer(runif(n = 5000,min = 1000000000,max=2000000000))
prefix=sample(x=prefixsam,size=5000,replace=TRUE)
first = sample(x = firstsam,size = 5000,replace = TRUE)
middle=sample(x=middlesam,size=5000,replace=TRUE)
last = sample(x=lastsam,size=5000,replace=TRUE)
suffix=sample(suffixsam,5000,replace=TRUE)
physnon=sample(physnonsam,5000,replace=TRUE)
specialty = sample(tmp$type,5000,replace=TRUE)
street=sample(streetsam,5000,replace=TRUE)
streetdos = sample(c(NA),5000,replace=TRUE)

## Generate sample zipcode df
tmp = zipcode[sample(nrow(zipcode),5000),]
##
city=tmp$city
state=tmp$state
county = sample(countysam,5000,replace=TRUE)
zip=tmp$zip
net = sample(networksam,5000,replace=TRUE)
fips=sample(c(15004,13006,25002),5000,replace=TRUE)
provcol=sample(c(NA),5000,replace=TRUE)

gen_prov=as.data.frame(cbind(npi,prefix,first,middle,last,suffix,physnon,specialty,street,streetdos,
                        city,state,county,zip,net,fips,provcol),stringsAsFactors=FALSE)

colnames(gen_prov)=c("National Provider Number (NPI)","Provider Name Prefix","First Name of Provider",
                      "Middle Initial of Provider","Last Name of Provider","Suffix of Provider",
                      "Physician / Non-Physician","Specialty Type  (area of medicine)",
                      "Street Address","Street Address 2","City","State","County",
                      "Zip","Network IDs","FIPS Code","ProvDirIND01of0218973IA252D20140722T115902"
)

write.table(x = gen_prov,file = "sample_prov_data.txt",sep = "\t")

## Change column name to Facility version.
gen_fac=gen_prov
colnames(gen_fac)=c("National Provider Number (NPI)","Provider Name Prefix","First Name of Provider",
                     "Middle Initial of Provider","Last Name of Provider","Suffix of Provider",
                     "Physician / Non-Physician","Facility Type*",
                     "Street Address","Street Address 2","City","State","County",
                     "Zip","Network IDs","FIPS Code","ProvDirIND01of0218973IA252D20140722T115902"
)
write.table(x=gen_fac,file="sample_fac_data.txt",sep="\t")