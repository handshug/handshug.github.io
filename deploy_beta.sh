#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Commit message is empty"
else
    message="${@}"
    rm -rf release/
    git clone https://github.com/betahug/betahug.github.io.git release
    echo "======================"
    echo "jekyll build"
    JEKYLL_ENV=production bundle exec jekyll build --destination release
    echo "======================"
    cd release
    echo "======================"
    echo "resize images"
    echo "======================"
    mogrify -resize '1440x1440>' assets/images/**/*.*
    echo "======================"
    echo "optimize images"
    echo "======================"
    for file in `find assets/images -name '*.png'`; do
        pngquant --verbose --speed 1 --force --ext '.png' ${file}
    done
    mogrify -sampling-factor 4:2:0 -strip -quality 85 -interlace JPEG -colorspace RGB assets/images/**/*.jpg
    mogrify -sampling-factor 4:2:0 -strip -quality 85 -interlace JPEG -colorspace RGB assets/images/**/*.jpeg
    echo "======================"
    echo "uglifyjs"
    echo "======================"
    find assets/js -name "*.js" | xargs cat | uglifyjs --compress --mangle -o assets/js/app.min.js
    echo "======================"
    echo "remove unused"
    find assets/js ! -name 'app.min.js' -type f -exec rm -f {} +
    rm -rf assets/js/vendor
    find assets/css ! -name 'app.min.css' -type f -exec rm -f {} +
    rm -rf assets/css/vendor
    echo "======================"
    echo "prepare commit"
    echo "======================"
    git add .
    git commit -m "$message"
    git remote add beta https://github.com/betahug/betahug.github.io.git
    echo "======================"
    echo "in release directory"
    echo "check remote beta by git remote -v"
    echo "git push beta master"
fi
