var gulp      = require("gulp");
var sequence  = require("run-sequence");
var del       = require("del");

gulp.task("build", function () {
  sequence(
    "clean",
    ["compile-coffee", "compile-sass"],
    "inlinesource",
    "clipboard"
  );
});

gulp.task("clean", function() {
  del(["./dest/*"]);
});

gulp.task("clipboard", function () {
  var clipboard = require("gulp-clipboard");

  return gulp.src("./dest/index.html")
    .pipe(clipboard())
});

gulp.task("compile-coffee", function () {
  var coffee = require("gulp-coffee");

  return gulp.src("./src/*.coffee")
    .pipe(coffee({bare: true}))
    .pipe(gulp.dest("./dest"));
});

gulp.task("compile-sass", function () {
  var sass         = require("gulp-sass");
  var postcss      = require("gulp-postcss");
  var autoprefixer = require("autoprefixer-core");

  return gulp.src("./src/*.scss")
    .pipe(sass())
    .pipe(postcss([ autoprefixer({ browsers: ["last 2 versions"] }) ]))
    .pipe(gulp.dest("./dest"));
});

gulp.task("copy-html", function () {
  // copy HTML files
  return gulp.src("./src/*.html")
    .pipe(gulp.dest("./dest"));
});

gulp.task("inlinesource", ["copy-html"], function () {
  var inlinesource = require("gulp-inline-source");

  return gulp.src("./dest/*.html")
    .pipe(inlinesource())
    .pipe(gulp.dest("./dest"));
});

gulp.task("watch", function () {
  return gulp.watch(["./src/*.html", "./src/*.coffee", "./src/*.scss"], ["build"]);
});
