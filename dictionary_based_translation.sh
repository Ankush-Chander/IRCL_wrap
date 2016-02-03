#! /bin/bash
echo $1;
echo $2;
source ./config.file
year="merged";
language_string="hi_gu_bn_ta_mr_te_en";

if [ "$1" == "$2" ];
then
	echo "srce and target language can not be same."
elif [[ "$language_string" =~ $1  && "$language_string" =~ $2 ]]
then
mkdir /home/hedgehog/temp 2> /dev/null
TEMP="/home/hedgehog/temp";
TOPIC_FILE=$TEMP"/topics.txt";
RESULT_TOPIC=$TEMP"/res_topics.txt";
INITIAL_TOPIC=$TEMP"/initial_topics.txt";
TEMP_FILE=$TEMP"/temp.txt";
B_TERRIER_HOME="$BASE_DIR/$2_terrier-4.0";
SOURCE_FILE=$B_TERRIER_HOME"/Queries/$year/mono/$1_$1.topics.txt";
ORIGINAL_FILE=$B_TERRIER_HOME"/Queries/$year/mono/$2_$2.topics.txt";
TARGET_FILE=$B_TERRIER_HOME"/Queries/$year/dictionary/$1_$2.topics.txt";
DICTIONARY_FILE="$BASE_DIR/Tools/Dictionaries/$1To$2Translation.txt"
STOPWORDS_FILE="/home/hedgehog/media/cerebrum/DAIICT/Thesis/Experiments/Tools/CLIA/$1-lib/stopwords_hi.txt"
#echo "cppying $ORIGINAL_FILE into $TARGET_FILE";

function generate_meaning {
	#word=$1
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
                   cat $DICTIONARY_FILE | grep "^$1\s" | cut -f2 | sed 'N;s/\n/ /'
               }

function stem_word {
	#word=$1
	#echo "%%% stemming $1 %%%%"
	printf "$1" | java -jar "/home/hedgehog/media/cerebrum/DAIICT/Thesis/Experiments/Tools/HiStem.jar"

}

cp $ORIGINAL_FILE $TARGET_FILE ;

touch $TEMP"/topics.txt";
#set up initial topics for replacement
cat $ORIGINAL_FILE | grep "<title>" > $INITIAL_TOPIC

#cat $INITIAL_TOPIC;

grep "<title>" $SOURCE_FILE | sed 's/<title>//g' | sed 's^</title>^^g' > $TOPIC_FILE
#cat $TOPIC_FILE;


for ((x=1; x<=100; x++))
do
	query=`awk "NR==$x" $TOPIC_FILE`;
	echo "*** $query ***";
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
done
rm -Rf $TEMP
else
	echo "invalid language chosen";
fi
