#! /bin/sh
 
# Delete first 4 pages(images) from manga chapters
gsutil -m rm -r gs://manga-dev-313513.appspot.com/**/**/0000[1-4].jpg