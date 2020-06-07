cd /Users/d.glua/git/blog

pwd
hugo --theme=hugo-ivy --baseUrl="https://blog.o0o0o0.de"

# 部署
cd ../muggleL
rm -rf css js categories post search tags note daily
rm *.html *.xml
mv ../blog_file/public/* ./
echo "开始部署"
git add *
git commit -m "update"
git push
