cd $HOME/git/blog_file
git add --all
git commit -m "$*"
git push
pwd
hugo --theme=hugo-ivy --baseUrl="https://blog.mygoooosh.com"

# 部署
cd ../muggleL
rm -rf css js categories post search tags note daily pdfs do-not-eat-those
rm *.html *.xml
mv ../blog_file/public/* ./
echo "开始部署"
git add *
git commit -m "$*"
git push
