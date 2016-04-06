#! /bin/bash

target_folder=$1

cd $target_folder
FILES=$(find $target_folder -type f )
for file in $FILES
do
echo $file
if [ "$file" != "/home/hedgehog/media/cerebrum/DAIICT/Thesis/Experiments/en_terrier-4.0/corpus/en.docs.2011/en_TheTelegraph_2001-2010/telegraph_1st_sep_2004_to_30th_sep_2007/2005_utf8/sports/1050121_sports_story_4280150.utf8" ]; then
article='"'"`sed -n '/<TEXT/,/<\/TEXT/{
      s!<TEXT>!!g
      s!</TEXT>!!g
      /^$/d
      s!\"!!g
      p
    }' $file`"'"'

echo $article >> $target_folder/combined.txt
fi
done
