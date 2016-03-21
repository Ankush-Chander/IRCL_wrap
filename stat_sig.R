#! /usr/bin/Rscript
args <- commandArgs(trailingOnly=TRUE)
#print(args[1])

engine <- args[1]
source_lang <- args[3]
target_lang <- args[4]

algo <- args[2]
#"Hiemstra_LM"

print(engine)
print(algo)
print(source_lang)
print(target_lang)

source_1_file_cmd <- paste("cat ", "/home/hedgehog/media/cerebrum/DAIICT/Thesis/Experiments/",target_lang,"_terrier-4.0/var/mono_results/merged/",target_lang,"_",target_lang,"/",algo,"/evaluation.txt  | grep 'map' | head -100 | cut -f3 | paste -d, -s",sep="")
A1=system(source_1_file_cmd, intern=TRUE)
a1=strsplit(A1,",")
array1=c(as.numeric(unlist(a1)))

source_2_file_cmd <- paste("cat ", "/home/hedgehog/media/cerebrum/DAIICT/Thesis/Experiments/",target_lang,"_terrier-4.0/var/",engine,"_results/merged/",source_lang,"_",target_lang,"/",algo,"/evaluation.txt  | grep 'map' | head -100 | cut -f3 | paste -d, -s",sep="")
A2=system(source_2_file_cmd, intern=TRUE)
a2=strsplit(A2,",")
array2=c(as.numeric(unlist(a2)))
t.test(array1, array2, paired=TRUE)
