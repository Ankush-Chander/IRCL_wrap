#! /bin/bash
echo $1;
echo $2;
year=2012;
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
B_TERRIER_HOME="/home/hedgehog/media/cerebrum/DAIICT/Thesis/Experiments/Tools/$2_terrier-4.0";
SOURCE_FILE=$B_TERRIER_HOME"/Queries/$year/original/$1_$1.topics.txt";
ORIGINAL_FILE=$B_TERRIER_HOME"/Queries/$year/original/$2_$2.topics.txt";
TARGET_FILE=$B_TERRIER_HOME"/Queries/$year/google/$1_$2.topics.txt";

#echo "cppying $ORIGINAL_FILE into $TARGET_FILE";
cp $ORIGINAL_FILE $TARGET_FILE ;

touch $TEMP"/topics.txt";
#set up initial topics for replacement
cat $ORIGINAL_FILE | grep "<title>" > $INITIAL_TOPIC

#cat $INITIAL_TOPIC;

#paid_key=AIzaSyAO0ItiP44wSgZUqxfs0SHNT77O5M0sZZY;
#free_key=AIzaSyD4o_zdslLTzDinurBCqpGMnCoaHQvokyI
base_query="https://www.googleapis.com/language/translate/v2?key=AIzaSyD4o_zdslLTzDinurBCqpGMnCoaHQvokyI&source=$1&target=$2";
query="https://www.googleapis.com/language/translate/v2?key=AIzaSyD4o_zdslLTzDinurBCqpGMnCoaHQvokyI&source=$1&target=$2";
grep "<title>" $SOURCE_FILE | sed 's/<title>//g' | sed 's^</title>^^g' > $TOPIC_FILE
#cat $TOPIC_FILE;


for ((x=1; x<=50; x++))
do
	url_encoded_query=`awk "NR==$x" $TOPIC_FILE | sed 's/ /%20/g'`;
	echo "*** $url_encoded_query ***";
	i=`expr $x % 5`;
	if [ $i -eq 0 ]
		then
			#echo "reset query";
			query=$query"&q=$url_encoded_query";
			#echo $query;
			curl $query >> $RESULT_TOPIC 
			query=$base_query;
	else
			query=$query"&q=$url_encoded_query";
			#echo "append to query";
	fi	
done

grep "translatedText" $RESULT_TOPIC  | sed 's/"translatedText": "//g' | sed 's/&#39;s//g' | sed 's/"//g' |  sed 's/    //g'> $TEMP_FILE
mv $TEMP_FILE $RESULT_TOPIC

for ((x=1; x<=50; x++))
do
	query=`awk "NR==$x" $RESULT_TOPIC`;
	echo "<title>"$query"</title>" >> $TEMP_FILE;
done
mv $TEMP_FILE $RESULT_TOPIC;

#cat $RESULT_TOPIC;

# putting translated queries back to new query file
for ((x=1; x<=50 ; x++))
do
	initial_topic="`awk "NR==$x" $INITIAL_TOPIC`";
	target_topic="`awk "NR==$x" $RESULT_TOPIC`";
#	echo $x;
#	echo $target_topic;
	cat $TARGET_FILE |   sed "s|$initial_topic|$target_topic|g" > $TEMP_FILE
	mv $TEMP_FILE $TARGET_FILE;
	#clear temporary files	
done
rm -Rf $TEMP
else
	echo "invalid language chosen";	
fi
