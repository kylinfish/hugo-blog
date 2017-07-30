const gulp = require('gulp'),
    htmlmin = require('gulp-html-minifier');

/*                                                                   oooo
 *                                                                   `888
 *      .oooooooo  .ooooo.  ooo. .oo.    .ooooo.  oooo d8b  .oooo.    888
 *     888' `88b  d88' `88b `888P"Y88b  d88' `88b `888""8P `P  )88b   888
 *     888   888  888ooo888  888   888  888ooo888  888      .oP"888   888
 *     `88bod8P'  888    .o  888   888  888    .o  888     d8(  888   888
 *     `8oooooo.  `Y8bod8P' o888o o888o `Y8bod8P' d888b    `Y888""8o o888o
 *     d"     YD
 *     "Y88888P'
 */

gulp.task('default', function() {
  return gulp.src('./public/**/*.html')
    .pipe(htmlmin({collapseWhitespace: true}))
    .pipe(gulp.dest('./public/'))
});
