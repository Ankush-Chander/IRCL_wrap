#! /bin/bash
source ./config.file
echo $1;
echo $2;
echo $3;

year=merged
engine='naive_dictionary'
if [[ "$3" == "" ]]
then
	model="InL2";
else
	model="$3";
fi

language_string="en_hi_gu_bn_ta_te";

if [[ "$language_string" =~ $1 && "$language_string" =~ $2 ]]
then
TERRIER_HOME="$BASE_DIR/$2_terrier-4.0"

result_file=$TERRIER_HOME/var/${engine}_results/$year/$1_$2/$model/results.res
eval_file=$TERRIER_HOME/var/${engine}_results/$year/$1_$2/$model/evaluation.txt
#echo $TERRIER_HOME/var/${engine}_results/$year/$1_$2/$model
mkdir -p $TERRIER_HOME/var/${engine}_results/$year/$1_$2/$model 2> /dev/null

cd $TERRIER_HOME

$TERRIER_HOME/bin/trec_terrier.sh -r -q -Dtrec.model="$model" -Dtrec.results.file="$result_file" -Dtrec.topics="$TERRIER_HOME/Queries/$year/$engine/$1_$2.topics.txt"

echo $TERRIER_HOME/Qrels/$year/$2.qrels.txt
echo $result_file
$TERRIER_HOME/trec_eval.8.1/trec_eval -q -c -M1000 $TERRIER_HOME/Qrels/$year/$2.qrels.txt $result_file > $eval_file
#mkdir $TERRIER_HOME/var/results/temp;
#mv $TERRIER_HOME/var/results/*.res* $TERRIER_HOME/var/results/temp/
#mkdir $TERRIER_HOME/var/results/$1_$2/ 2> /dev/null
#mv $TERRIER_HOME/var/results/temp/* $TERRIER_HOME/var/results/$1_$2/$model/
#mv $TERRIER_HOME/var/results/$1_$2_results.txt   $TERRIER_HOME/var/results/$1_$2/$model/
#rmdir $TERRIER_HOME/var/results/temp
#rm $TERRIER_HOME/var/results/querycounter
cat $eval_file | grep "map.*all" | sed "s/map.*all/MAP=/g"
else
echo "invalid run";
fi
