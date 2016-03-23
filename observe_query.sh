# find two target files to compare machine/human
#! /bin/bash
source ./config.file
echo $1;
echo $2;
year=merged
model=InL2
engine=wordvec_dictionary

#TEMP="/home/latebloomer/temp";
TERRIER_WD="$BASE_DIR/${2}_terrier-4.0"
SOURCE_QUERY_FILE=$TERRIER_WD"/Queries/$year/mono/$1_$1.topics.txt"

HUMAN_TRANSLATED_FILE=$TERRIER_WD"/Queries/$year/mono/$2_$2.topics.txt"
MACHINE_TRANSLATED_FILE=$TERRIER_WD"/Queries/$year/$engine/$1_$2.topics.txt"
OBSERVATION_FOLDER=$TERRIER_WD"/var/observations/$engine/$year"
OBSERVATION_FILE=$OBSERVATION_FOLDER"/$1_$2_new_observations.txt"
language_string="en_hi_gu_bn_ta_te";

mkdir -p $OBSERVATION_FOLDER
touch $OBSERVATION_FILE
#create folder for temp files
mkdir $TEMP_DIR 2> /dev/null
mkdir $OBSERVATION_FOLDER 2> /dev/null

if [[ $1 != "" && $2 != "" && "$language_string" =~ $1 && "$language_string" =~ $2 ]]
then

cd $TERRIER_WD
cat $TERRIER_WD"/var/${engine}_results/$year/$1_$2/$model/evaluation.txt" | grep "map" | sort -k3 | cut -f2 > $TEMP_DIR/"culprit_queries.txt"
#loop over query ids and display details
#echo "QueryId | Source query | Machine translated query | Human translated query | MAP differnce | Problem" > $OBSERVATION_FILE
while read line
do
    echo -n "$line |";
    echo -n "$line" |
    #echo -n "Source query:"
    sed -n "/$line/{
    	n
    	p
    }
    " $SOURCE_QUERY_FILE  | sed  '{s^<title>^^
     s^</title>^^;
 	}' | tr '\n' ' '
    echo -n "|"
    #echo -n "Machine translated query:"
    sed -n "/$line/{
    	n
    	p
    }
    " $MACHINE_TRANSLATED_FILE  | sed '{s^<title>^^
     s^</title>^^;
 		}' |  tr '\n' ' '
    #echo -n "Human translated query:"
    echo -n "|";
    sed -n "/$line/{
    	n
    	p
    }
    " $HUMAN_TRANSLATED_FILE | sed '{s^<title>^^
     s^</title>^^;
 	}' | tr '\n' ' '
    echo -n "|";
# find map difference
#$TERRIER_WD"/var/mono_results/$year/$2_$2/$model/evaluation.txt"
    tr_map=`cat $TERRIER_WD"/var/${engine}_results/$year/$1_$2/$model/evaluation.txt" | sed -n "/map/p" | sed -n "/\b$line\b/p" | cut -f3`
    or_map=`cat $TERRIER_WD"/var/mono_results/$year/$2_$2/$model/evaluation.txt" | sed -n "/map/p" | sed -n "/\b$line\b/p" | cut -f3`
	#echo "helo";
	#echo "$tr_map";
	#echo "hello"
	#echo "$or_map"
	map_difference="`echo $tr_map-$or_map | bc`";
	map_difference_fraction="`echo $map_difference/$or_map | bc`";
	map_difference_percentage="`echo $map_difference*100 | bc`";
    echo "$map_difference_percentage";
    #echo "Problem:"
    #echo "=============================================================="
done < $TEMP_DIR/"culprit_queries.txt" > $OBSERVATION_FILE
echo $OBSERVATION_FILE
cat $OBSERVATION_FILE | sort -t"|" -n -k5 | sed -n '/all |/!p'> $TEMP_DIR"/temp.txt"
mv $TEMP_DIR"/temp.txt" $OBSERVATION_FILE

#sed -n '/all |/!p' $OBSERVATION_FILE > $TEMP_DIR"/temp.txt"
#mv $TEMP_DIR"/temp.txt" $OBSERVATION_FILE


over_performers=`awk 'BEGIN{FS="|"};$5>0{print $0}' $OBSERVATION_FILE | wc -l`
under_performers=`awk 'BEGIN{FS="|"};$5<0{print $0}' $OBSERVATION_FILE | wc -l`
consistent_performers=`awk 'BEGIN{FS="|"};$5==0{print $0}' $OBSERVATION_FILE | wc -l`
echo  "over_performers:" $over_performers;
echo  "under_performers:" $under_performers ;
echo  "consistent_performers:" $consistent_performers;



#Temporary files cleanup
rm -Rf $TEMP_DIR;
else
	echo "error:Invalid Language Chosen";
	echo "Valid languages are:";
	echo "English: en";
	echo "Hindi: hi";
	echo "Bengali: bn";
	echo "Tamil: ta";
	echo "Telugu: te";
fi
