require('gulp-lazyload')
  gulp:       'gulp'
  connect:    'gulp-connect'
  concat:     'gulp-concat'
  coffee:     'gulp-coffee'
  preprocess: 'gulp-preprocess'
  iife:       'gulp-iife-wrap'
  uglify:     'gulp-uglify'
  rename:     'gulp-rename'
  del:        'del'
  plumber:    'gulp-plumber'
  replace:    'gulp-replace'

gulp.task 'default', ['build', 'watch'], ->

dependencies = [
  {require: 'yess', global: '_'}
  {global: 'Error', native: yes}
  {global: 'Object', native: yes}
]

gulp.task 'build', ->
  gulp.src('source/construct-with.coffee')
  .pipe plumber()
  .pipe preprocess()
  .pipe iife({global: 'ConstructWith', dependencies})
  .pipe concat('construct-with.coffee')
  .pipe replace(/PARAMS/g, "'_1'")
  .pipe gulp.dest('build')
  .pipe coffee()
  .pipe concat('construct-with.js')
  .pipe gulp.dest('build')

gulp.task 'build-min', ['build'], ->
  gulp.src('build/construct-with.js')
  .pipe uglify()
  .pipe rename('construct-with.min.js')
  .pipe gulp.dest('build')

gulp.task 'watch', ->
  gulp.watch 'source/**/*', ['build']

gulp.task 'coffeespec', ->
  del.sync 'spec/**/*'
  gulp.src('coffeespec/**/*.coffee')
  .pipe coffee(bare: yes)
  .pipe gulp.dest('spec')
  gulp.src('coffeespec/support/jasmine.json')
  .pipe gulp.dest('spec/support')
