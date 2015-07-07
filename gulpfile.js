var gulp = require('gulp'),
  sourcemaps = require('gulp-sourcemaps'),
  source = require('vinyl-source-stream'),
  babel = require('gulp-babel'),
  babelify = require('babelify'),
  browserify = require('browserify'),
  concat = require('gulp-concat'),
  postcss = require('gulp-postcss'),
  autoprefixer = require('autoprefixer'),
  lost = require('lost');

var paths = {
  cssSrc: 'src/css/',
  cssDest: 'public/css/',
  jsSrc: 'src/js/',
  jsDest: 'public/js/'
};

gulp.task('es6', function() {
  browserify({
    entries: './src/js/app.js',
    debug: true
  })
  .transform(babelify)
  .bundle()
  .pipe(source('app.js'))
  .pipe(gulp.dest(paths.jsDest));
});

gulp.task('css', function() {
  return gulp.src(paths.cssSrc + '**/*.css')
    .pipe(sourcemaps.init())
    .pipe(postcss([
      lost(),
      autoprefixer()
    ]))
    .pipe(sourcemaps.write('./'))
    .pipe(gulp.dest(paths.cssDest));
});

gulp.task('watch', function() {
  gulp.watch(paths.jsSrc, ['es6']);
  gulp.watch(paths.cssSrc, ['css']);
});

gulp.task('default', ['watch','css', 'es6']);
gulp.task('build', ['css', 'es6']);
