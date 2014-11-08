gulp = require 'gulp'
webserver = require 'gulp-webserver'

gulp.task 'default', [ 'webserver' ]

gulp.task 'webserver', ->
  gulp.src './'
    .pipe webserver
      livereload: true
