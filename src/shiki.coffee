###
# shiki.coffee
# (c) spring_raining
# CC BY 4.0
###

$ ->
  nowFetching = false
  nextPageURL = []
  finalPage = false
  isDesktop = false
  appearingPosts = {}

  windowAspect = ->
    if isDesktop then window.innerHeight / window.innerWidth else firstWindowAspect

  windowInnerHeight = ->
    if isDesktop then window.innerHeight else firstInnerHeight

  windowInnerWidth = ->
    if isDesktop then window.innerWidth else firstInnerWidth

  firstWindowAspect = window.innerHeight / window.innerWidth
  firstInnerHeight = window.innerHeight
  firstInnerWidth = window.innerWidth

  initializeCSS = ->
    if $("body").hasClass "page-permalink"
      # photoset iframe内CSS変更
      $("iframe.photoset").load ->
        console.log "load"
        $(this).contents().find ".photoset_row"
          .css "width", "680px"
          .css "margin", "10px"
          .css "border-radius", "6px"

  updatePhotoCSS = ($photo) ->
    heightInfluenceParam = 0.6
    mobileHeightInfluenceParam = 0.7
    photoAspect = $photo.attr("data-shiki-photoHeight") / $photo.attr("data-shiki-photoWidth")
    $photo.attr "data-shiki-photoAspect", photoAspect

    if $("body").hasClass "page-index"
      if isDesktop
        areaHeight = windowInnerWidth() * photoAspect * heightInfluenceParam
        if areaHeight > windowInnerHeight()
          areaHeight -= (areaHeight - windowInnerHeight()) * (1 - heightInfluenceParam)

        areaAspect = areaHeight / windowInnerWidth()
        $photo.css("background-size", if photoAspect > areaAspect then windowInnerWidth() + "px auto" else "auto " + areaHeight + "px")
          .attr "data-shiki-areaHeight", areaHeight
        $photo.parents ".photo-block"
          .css "height", areaHeight + "px"

        $photo.parents(".entry-container").children(".hover-area")
          .on "mouseenter", (e) ->
            $(this).addClass "show hover"
          .on "mouseleave", (e) ->
            $(this).removeClass "show hover"
      else
        areaHeight = (windowInnerHeight() * (1 - mobileHeightInfluenceParam)) + (windowInnerWidth() * photoAspect * mobileHeightInfluenceParam)
        areaAspect = areaHeight / windowInnerWidth()
        $photo
          .css("height", areaHeight + "px")
          .css("background-size", if photoAspect > areaAspect then windowInnerWidth() + "px auto" else "auto " + areaHeight + "px")
          .css("background-position", "center")
          .attr("data-shiki-areaHeight", areaHeight)
        console.log areaHeight

    if $("body").hasClass "page-permalink"
      $photo.css("background-size", "100vw auto")
        .css("height", windowInnerWidth() * photoAspect + "px")
        .css("background-position", "center")
        .attr("data-shiki-areaHeight", windowInnerWidth() * photoAspect)
      $photo.parents(".entry-container")
        .css("width", "100vw")
    $photo

  if $("body").hasClass "page-index"
    updatePhotoPosition = ($photo) ->
      if $photo.css("background-image") is "none"
        $photo.css("background-image", "url(" + $photo.attr("data-shiki-photoURL") + ")")

      relativeTop = $(window).scrollTop() - $photo.parents(".photo-block").offset().top
      areaWidth  = windowInnerWidth()
      areaHeight =  parseFloat($photo.attr("data-shiki-areaHeight"))
      photoWidth  = parseInt($photo.attr("data-shiki-photoWidth"))
      photoHeight = parseInt($photo.attr("data-shiki-photoHeight"))
      scrollRate = if (windowAspect() / 2 > areaHeight / areaWidth) \
        then (windowInnerHeight() - areaHeight + relativeTop) / (windowInnerHeight()) \
        else (relativeTop + windowInnerHeight()) / (windowInnerHeight() + areaHeight / 2)
      topDiff = areaHeight * (scrollRate - 0.5) * 2
      topDiff += (areaHeight - photoHeight * areaWidth / photoWidth) * (scrollRate)
      topDiff = (1 - scrollRate) * (areaHeight - (photoHeight * areaWidth / photoWidth))
      $photo.css("transform", "translate3d(0,"+topDiff+"px,0)")
      $photo

    updateHeaderCSS = ->
      $("header#header").css("height", windowInnerHeight() * 0.5 + "px")

  fetchNextPage = (url) ->
    d = new $.Deferred()
    $.ajax({
      type:     "GET",
      url:      url,
      success:  d.resolve,
      error:    d.reject
    })
    d.promise()

  # スマホ振り分け
  if navigator.userAgent.indexOf("Mobile") > 0 || navigator.userAgent.indexOf("Android") > 0
    $("body").addClass("mobile")
    isDesktop = false
  else
    $("body").addClass("desktop")
    isDesktop = true

  if $("body").hasClass "page-index"
    if isDesktop
      $(".navbar")
        .on "mouseenter", (e) ->
          $(this).addClass("show hover")
        .on "mouseleave", (e) ->
          $(this).removeClass("hover")
          if $(window).scrollTop() > 100
            $(this).removeClass("show")
    else
      $(".nav-handle").on "click", (e) ->
        $(this).parents(".navbar").toggleClass("show hover")
      $(".header-container").css("height", windowInnerHeight() / 2 + "px")

  if $("body").hasClass "page-permalink"
    $(".photo-container").each ->
      $(this).css("background-image", "url(" + $(this).attr("data-shiki-photoURL") + ")")
      updatePhotoCSS($(this))

  $(window).scroll ->
    height = $(this).scrollTop()

    # Photo/PhotoSet
    if $("body").hasClass "page-index"
      $(".photo-container").each ->
        relativeTop = height - $(this).offset().top
        url = $(this).attr("data-shiki-photoURL")
        if -window.innerHeight - 400 <= relativeTop && window.innerHeight + 1600 >= relativeTop
          if $(this).css("background-image") is "none"
            $(this).css("background-image", "url(" + $(this).attr("data-shiki-photoURL") + ")")
            updatePhotoCSS($(this))
            appearingPosts[url] = $(this)
        else
          if $(this).css("background-image") isnt "none"
            delete appearingPosts[url]
            $(this).css("background-image", "none")

    # YouTube
    $("article.video .video-iframe").each ->
      $iframe = $(this).children("iframe")
      aspect = $iframe.attr("height") / $iframe.attr("width")
      $(this).css("padding-top", (aspect * 100) + "%")

    # SoundCloud
    $("article.audio .video-iframe").each ->
      $iframe = $(this).children("iframe")
      aspect = $iframe.attr("height") / $iframe.attr("width")
      $(this).css("padding-top", (aspect * 100) + "%")

    if $("body").hasClass "page-index"
      # Photo背景アップデート
      for k, $v of appearingPosts
        relativeTop = height - $v.parents(".photo-block").offset().top
        areaHeight = parseInt($v.attr("data-shiki-areaHeight"))
        if (relativeTop + windowInnerHeight()) / (windowInnerHeight() + areaHeight) >= 0 && (relativeTop + windowInnerHeight()) / (windowInnerHeight() + areaHeight) <= 1
          if isDesktop
            updatePhotoPosition $v

      # オートページャー
      if !nowFetching && !finalPage && $(document).height() - (height + window.innerHeight) < 1000
        if nextPageURL.length isnt 0
          nowFetching = true
          url = nextPageURL.shift()
          fetchNextPage(url).then (data) ->
            $(data).find("article").appendTo("#main")
            nextPageURL = []
            $(data).find(".next-url").each ->
              nextPageURL.push($(this).attr("data-shiki-nextPageURL"))
            nowFetching = false
            $(window).trigger("resize")
          , (data) ->
            # fetch next nextPageURL
            nowFetching = false
            $(window).trigger "scroll"
        else
          $("#main").append('<p style="opacity:0.4; text-align: center;">:)</p>')
          finalPage = true

    # ヘッダー移動
    if isDesktop
      $navbar = $(".navbar")
      if height <= 100
        $navbar.addClass "show"
      else if !$navbar.hasClass "hover"
        $navbar.removeClass "show"

  $(window).resize ->
    $(window).trigger "scroll"
    if $("body").hasClass "page-index"
      updateHeaderCSS()
    if $("body").hasClass "page-permalink"
      $(".photo-container").each ->
        updatePhotoCSS($(this))

  $(".next-url").each ->
    nextPageURL.push($(this).attr("data-shiki-nextPageURL"))

  # ↑All preparations have done↑
  $(document).ready ->
    initializeCSS()
    $(window).trigger("resize")