#! /bin/bash
#echo $1;
#echo $2;
source ./config.file
year="merged";
source_engine="mono" #mono or qe
engine="naive_dictionary"
language_string="hi_gu_bn_ta_mr_te_en";

sl=$1
tl=$2

TOPIC_FILE="$TEMP_DIR/topics.txt";
RESULT_TOPIC="$TEMP_DIR/res_topics.txt";
INITIAL_TOPIC="$TEMP_DIR/initial_topics.txt";
TEMP_FILE="$TEMP_DIR/temp.txt";
S_TERRIER_HOME="$BASE_DIR/$1_terrier-4.0";
T_TERRIER_HOME="$BASE_DIR/$2_terrier-4.0";
SOURCE_FILE="$S_TERRIER_HOME/Queries/$year/$source_engine/$1_$1.topics.txt";
TARGET_FILE="$T_TERRIER_HOME/Queries/$year/$engine/$1_$2.topics.txt";
ORIGINAL_FILE="$T_TERRIER_HOME/Queries/$year/mono/$2_$2.topics.txt";
DICTIONARY_FILE="$BASE_DIR/Tools/Dictionaries/$1To$2Translation.txt"
#NEW_DICTIONARY_FILE="$BASE_DIR/Tools/Dictionaries/UW_Hindi_Dict_20131003/UW-Hindi_Dict-20131003.txt"
STOPWORDS_FILE="$BASE_DIR/Tools/CLIA/$1-lib/stopwords_$1.txt"
#echo "cppying $ORIGINAL_FILE into $TARGET_FILE";

mkdir $TEMP_DIR 2> /dev/null
mkdir -p "$T_TERRIER_HOME/Queries/$year/$engine" 2> /dev/null
	#word=$1
function generate_meaning {
	# first dictionary lookup
	meaning="`dictionary_lookup $1`"
	if [ "$meaning" != "" ]
	then
		#echo "meaning of word: $meaning"
		printf "$meaning "
	else
		#stem the word
		c_word="`stem_word $1`"
		# second dictionary lookup after stemming
		meaning="`dictionary_lookup $c_word`"
		if [ "$meaning" != "" ]
		then
			#echo "meaning of stemmed $word : $meaning"
			printf "$meaning "
		else
			printf "transliterate_$c_word "
		fi
	fi
}

function is_stop_word {
		grep "$1" $STOPWORDS_FILE
}

function dictionary_lookup {
                   #echo "meaning of "$1
                   #cat $DICTIONARY_FILE | grep "^$1\s" | cut -f2 | sed 'N;s/\n/, /'
									 cat $DICTIONARY_FILE | grep "^$1\s[a-z]*$" | cut -f2 | xargs echo -n | sed 's/ /, /g' | tr -d '.'
               }


function stem_word {
	#word=$1
	#echo "%%% stemming $1 %%%%"
	############################## WARNING: HARD CODE AHEAD #############################################
	if [ "$sl"=="hi" ]; then
	printf "$1" | java -jar "/home/hedgehog/media/cerebrum/DAIICT/Thesis/Experiments/Tools/hiStem.jar"
elif [ "$sl"=="te" ]; then
		printf "$1" | java -jar "/home/hedgehog/media/cerebrum/DAIICT/Thesis/Experiments/Tools/teStem.jar"
elif [ "$sl"=="bn" ]; then
		printf "$1" | java -jar "/home/hedgehog/media/cerebrum/DAIICT/Thesis/Experiments/Tools/bnStem.jar"
elif [ "$sl"=="hi" ]; then
		printf "$1" | java -jar "/home/hedgehog/media/cerebrum/DAIICT/Thesis/Experiments/Tools/hiStem.jar"
	fi
}


function transliterate_using_google {

#cat $1
TEMP_TARGET_FILE=$1
cat $1 | sed 's! !\n!g'  | grep "transliterate_" | sed "s/transliterate_//g" > $TEMP_DIR/"source_translitrate.txt"
cat $TEMP_DIR/"source_translitrate.txt" | xclip -selection clipboard
touch $TEMP_DIR/"target_translitrate.txt"
echo "mannually translate  $TEMP_DIR/"source_translitrate.txt into $TEMP_DIR/"target_translitrate.txt using google"
echo "press Y to continue and N to exit:"
read response

if [ "$response" == "Y" ];
	 then
	 xclip -o > $TEMP_DIR/target_translitrate.txt
	 for ((x=1; x<=`cat $TEMP_DIR/source_translitrate.txt | wc -l` ; x++))
	 do
	 	initial_topic="transliterate_"`awk "NR==$x" $TEMP_DIR/source_translitrate.txt`" ";
	 	target_topic=`awk "NR==$x" $TEMP_DIR/target_translitrate.txt | tr -d '.'`" ";
	 #	echo $x;
	 #	echo $target_topic;
	 	cat $TEMP_TARGET_FILE |   sed "s|$initial_topic|$target_topic|g" > $TEMP_FILE
	 	mv $TEMP_FILE $TEMP_TARGET_FILE;
	 	#clear temporary files
	 done
	 	echo "replaced transliterated text "
		cat $TEMP_TARGET_FILE
		#mv $TEMP_TARGET_FILE $TARGET_FILE
		#make transliterated topics replacement ready
		for ((x=1; x<=100; x++))
		do
			query=`awk "NR==$x" $TEMP_TARGET_FILE`;
			echo "<title>"$query"</title>" >> $TEMP_FILE;
		done
		mv $TEMP_FILE $RESULT_TOPIC;


		# putting translated queries back to new query file
		for ((x=1; x<=100 ; x++))
		do
			initial_topic="`awk "NR==$x" $INITIAL_TOPIC`";
			target_topic="`awk "NR==$x" $RESULT_TOPIC`";
		#	echo $x;
		#	echo $target_topic;
			cat $TARGET_FILE |   sed "s|$initial_topic|$target_topic|g" > $TEMP_FILE
			mv $TEMP_FILE $TARGET_FILE;
		done
			#clear temporary files

else
		echo " exit "
fi
}


if [ "$1" == "$2" ];
then
	echo "srce and target language can not be same."
elif [[ "$language_string" =~ $1  && "$language_string" =~ $2 ]]
then
mkdir $TEMP_DIR 2> /dev/null
cp $ORIGINAL_FILE $TARGET_FILE ;

touch $TEMP_DIR"/topics.txt";
#set up initial topics for replacement
cat $ORIGINAL_FILE | grep "<title>" > $INITIAL_TOPIC

#cat $INITIAL_TOPIC;

grep "<title>" $SOURCE_FILE | sed 's/<title>//g' | sed 's^</title>^^g' > $TOPIC_FILE
#cat $TOPIC_FILE;


for ((x=1; x<=100; x++))
do
	query=`awk "NR==$x" $TOPIC_FILE`;
#	echo "*** $query ***";
  OLDIFS=$IFS;
  IFS=' ';
  for word in `printf "$query"`;
  do
		#echo "`is_stop_word $word`"
		if [ "`is_stop_word $word`"  == "" ]
			then
			  #echo "`is_stop_word $word`"
				#echo "$word is not stop word"
				generate_meaning $word;
		else
			#echo "$word is stop word"
			continue;
		fi
    #lookup in dictionary
  done;
  IFS=$OLDIFS
	printf "\n"
done  > $TEMP_DIR/interm_target.txt
#cat $TEMP_DIR/interm_target.txt

transliterate_using_google $TEMP_DIR/interm_target.txt
else
	echo "invalid language chosen";
fi
rm -Rf $TEMP_DIR
