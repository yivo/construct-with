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
  {require: 'lodash', global: '_'}
  {require: 'yess'}
]

gulp.task 'build', ->
  gulp.src('source/manifest.coffee')
  .pipe plumber()
  .pipe preprocess()
  .pipe iife {global: 'ConstructWith', dependencies}
  .pipe concat('construct-with.coffee')
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
  del.sync 'spec/**/*.js'
  gulp.src('coffeespec/**/*.coffee')
  .pipe coffee(bare: yes)
  .pipe gulp.dest('spec')