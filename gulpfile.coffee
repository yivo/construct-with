gulp        = require 'gulp'
connect     = require 'gulp-connect'
concat      = require 'gulp-concat'
coffee      = require 'gulp-coffee'
preprocess  = require 'gulp-preprocess'
iife        = require 'gulp-iife'
uglify      = require 'gulp-uglify'
rename      = require 'gulp-rename'
del         = require 'del'
plumber     = require 'gulp-plumber'

gulp.task 'default', ['build', 'watch'], ->

dependencies = [
  {name: 'lodash', as: '_'}
  {name: 'yess', as: 'yess'}
  {name: 'coffee-concerns'}
]

gulp.task 'build', ->
  gulp.src('source/manifest.coffee')
  .pipe plumber()
  .pipe preprocess()
  .pipe iife {global: 'StrictParameters', dependencies}
  .pipe concat('strict-parameters.coffee')
  .pipe gulp.dest('build')
  .pipe coffee()
  .pipe concat('strict-parameters.js')
  .pipe gulp.dest('build')

gulp.task 'build-min', ['build'], ->
  gulp.src('build/strict-parameters.js')
  .pipe uglify(preserveComments: 'all')
  .pipe rename('yess.min.js')
  .pipe gulp.dest('build')

gulp.task 'watch', ->
  gulp.watch 'source/**/*', ['build']

gulp.task 'coffeespec', ->
  del.sync 'spec/**/*.js'
  gulp.src('coffeespec/**/*.coffee')
  .pipe coffee(bare: yes)
  .pipe gulp.dest('spec')