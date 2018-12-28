const gulp = require('gulp'),
    htmlmin = require('gulp-html-minifier'),
    minifyjs = require('gulp-js-minify'),
    purify = require('gulp-purifycss'),
    cleanCSS = require('gulp-clean-css'),
    imagemin = require('gulp-imagemin'),
    newer = require('gulp-newer'),
    del = require("del");


function refineImage()
{
  return gulp.src('./public/img/*')
    .pipe(newer('./public/img/*'))
    .pipe(
      imagemin([
        imagemin.gifsicle({ interlaced: true }),
        imagemin.jpegtran({ progressive: true }),
        imagemin.optipng({ optimizationLevel: 5 }),
        imagemin.svgo({
          plugins: [
            {
              removeViewBox: false,
              collapseGroups: true
            }
          ]
        })
      ])
    )
    .pipe(gulp.dest("./_site/assets/img"));
}

function refineHTML()
{
    return gulp.src('./public/**/*.html')
    .pipe(htmlmin({collapseWhitespace: true, conservativeCollapse: true}))
    .pipe(gulp.dest('./public/'))
}

function refineCSS() {
    // gallery modules
     gulp.src('./public/modules/gallery/css/*.css')
    .pipe(cleanCSS({compatibility: '*'}))
    .pipe(gulp.dest('./public/modules/gallery/css'));

    // blog
    return gulp.src("./public/css/**/*.css")
    .pipe(purify(['./public/css/**/*.css', './public/**/*.html']))
    .pipe(cleanCSS({compatibility: '*'}))
    .pipe(gulp.dest('./public/css/'));;
}

function refineJS() {
    // gallery modules
    gulp.src('./public/modules/gallery/js/**/*.js')
    .pipe(minifyjs())
    .pipe(gulp.dest('./public/modules/gallery/js'));

    // blog
    return gulp.src('./public/js/**/*.js')
    .pipe(minifyjs())
    .pipe(gulp.dest('./public/js'));
}

// gulp.task("images", images);
gulp.task("refineCSS", refineCSS);
gulp.task("refineJS", refineJS);
gulp.task("refineImage", refineImage);

gulp.task("build", gulp.series(gulp.parallel(refineCSS, refineJS, refineHTML)));

