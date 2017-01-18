if [ $# -eq 1 ];then
	if [ ! -d "${1}" ];then
		echo "Dir doesn't exist"
		exit 1
	fi
else
	echo "Please specify a dir"
	exit 1
fi




#cp file
cp merge_comments_and_postsanswers.py merge_answers_and_posts.py merge_links.py ${1}/. || exit 1
pushd $1



#Remove start and end of xml file
sed -e '1d' -e '2d' -e '$d' comments.xml > comments_withoutstartend.xml || exit 1
sed -e '1d' -e '2d' -e '$d' posts.xml > posts_withoutstartend.xml || exit 1


#sort comments.xml
sort -t '"' -k4,4n comments_withoutstartend.xml > comments_sort.xml || exit 1

#Associate comment and posts/answers
time python merge_comments_and_postsanswers.py 2 posts_withoutstartend.xml 4 comments_sort.xml > tmp.xml || exit 1

#Split file 
#Posttype2 in tmp_posts2.xml
sed 's/.*PostTypeId="[^2]".*//g' tmp.xml |grep -v "^$"|sort -t '"' -k6,6n > tmp_posts2.xml || exit 1

#posttype1 in tmp_posts1.xml
sed 's/.*PostTypeId="[^1]".*//g' tmp.xml |grep -v "^$"|sort -t '"' -k2,2n> tmp_posts1.xml || exit 1


#get liste of id<=>title
sed 's/.*row Id="\([0-9]*\).*Title="\([^"]*\).*/\1,"\2"/g' tmp_posts1.xml > id_title.csv || exit 1
#prepare links
sed -e '1d' -e '2d' -e '$d' postlinks.xml > postlinks_withoutstartend.xml || exit 1
sort -t '"' -k6,6n postlinks_withoutstartend.xml > postlinks_sort.xml || exit 1
time python merge_links.py postlinks_sort.xml id_title.csv > links_prepare.xml || exit 1
sort -t '"' -k8,8n links_prepare.xml | sed 's/<row/<link/g' > links_prepare_sort.xml || exit 1

#Associate posts and answers
time python merge_answers_and_posts.py 2 tmp_posts1.xml 6 tmp_posts2.xml 8 links_prepare_sort.xml > prepare.xml || exit 1

rm merge_links.py merge_answers_and_posts.py merge_comments_and_postsanswers.py comments_sort.xml tmp.xml tmp_posts2.xml tmp_posts1.xml comments_withoutstartend.xml posts_withoutstartend.xml postlinks_sort.xml id_title.csv postlinks_withoutstartend.xml links_prepare.xml links_prepare_sort.xml

popd
echo "Prepare: it's done !" 