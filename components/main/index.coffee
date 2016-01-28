$(()->
#    Navigation
    $page = $('html,body');
    $body = $('body');
    $window = $(window);
    windowHeight = 0;

    scrollToElement = (target) ->
        y = 0;

        if target && $(target).length
            y = $(target).offset().top;

        $page.stop().animate({scrollTop: y}, 'slow', 'swing');


    $body.on('click', '#top-menu a , #bottom-menu a , #about-us', (e) ->
        e.preventDefault();
        scrollToElement($(this).attr('href'));
    );

#    Top Slider
    dSlideSpeed = 50;
    $adderSpan = '';
    slideNum = 0;
#    dTimeOut = 8000;
#    dNeedLinks = false;
#    slideTime = '';
#    onePause = false;

    slideCount = $('#slider .slide').size();
    animSlide = (arrow) ->
        console.log(42);
#        clearTimeout(slideTime);
        if slideNum == arrow then return true;
        $('.slide').eq(slideNum).fadeOut(dSlideSpeed);
#        if arrow == 'next'
#            if slideNum == (slideCount-1) then slideNum=0 else slideNum++;
#        else if arrow == 'prew'
#            if slideNum == 0 then slideNum=slideCount-1 else slideNum-=1;
#        else
        slideNum = arrow;

#        $('.slide').eq(slideNum).addClass('flip').siblings().removeClass('flip');
        $('.slide').eq(slideNum).fadeIn(dSlideSpeed, rotator);
        $('.control-slide.active').removeClass('active');
        $('.control-slide').eq(slideNum).addClass('active');

        $('.services-provide-block ul li:eq(' + slideNum + ')').addClass('active').siblings().removeClass('active');

    sliderResize = () ->
        slider = $('#slider');
        imgH = $('#slider .slide img').height();
        imgH2 = $('#slider .slide.flip img').height();
        if $window.width() <= 568
            if imgH<=0
                slider.css('height', imgH2 + 'px');
            else
                slider.css('height', imgH + 'px');

    rotator = () ->
#        if !onePause
#            slideTime = setTimeout(
#                ()->
#                    animSlide('next')
#            dTimeOut);

    $('.slide').each((index)->
        $adderSpan += '<span class = "control-slide">' + index + '</span>'
        return true;
    );

    text = '<div class ="sli-links">' + $adderSpan + '</div>';
    $(text).appendTo('#slider-wrap');
    $('.control-slide:first').addClass('active');
    $('.control-slide').click(() ->
        console.log(4);
        goToNum = parseFloat($(this).text());
        animSlide(goToNum);
    );

#    $('#slider-wrap').hover(
#        ()->
#            clearTimeout(slideTime);
#            onePause = true;
#            return true;
#        ()->
#            onePause = false;
#            rotator();
#            return true;
#    );

#    rotator();

#    Awards slider
    awardSlideSpeed = 600;
    awardTimeOut = 4000;
    awardNeedLinks = true;
    awardSlideNum = 0;
    awardSlideTime = '';
    awardSlideCount = $('.our-awards-slider .award-img').size();
    twoPause = false;

    awardSlide = (arrow)->
        clearTimeout(awardSlideTime);
        $('.award-img').eq(awardSlideNum).fadeOut(awardSlideSpeed);
        if arrow == 'next'
            if awardSlideNum == (awardSlideCount-1)
                awardSlideNum=0;
            else
                awardSlideNum++;
        else if arrow == 'prew'
            if awardSlideNum == 0
                awardSlideNum=awardSlideCount-1;
            else
                awardSlideNum-=1;
        else
            awardSlideNum = arrow;

        $('.award-img').eq(awardSlideNum).fadeIn(awardSlideSpeed, rotatorAward);


    rotatorAward = () ->
        if !twoPause
            awardSlideTime = setTimeout(
                ()->
                    awardSlide('next')
            awardTimeOut);

    if awardNeedLinks
        $linkArrow = $('<span id="prewbutton">&nbsp;</span><span id="nextbutton">&nbsp;</span>').appendTo('.our-awards-slider');
        $('#nextbutton').click(()->
            awardSlide('next');
        );

        $('#prewbutton').click(()->
            awardSlide('prew');
        );

    $('.our-awards-slider').hover(
        ()->
            clearTimeout(awardSlideTime);
            twoPause = true;
        ()->
            twoPause = false;
    );
    rotatorAward();

#    Google map
    initialize = () ->
        secheltLoc = new google.maps.LatLng(54.10506, 45.10594);
        myMapOptions = {
            scrollwheel: false
            draggable: false
            zoom: 10
            center: secheltLoc
            mapTypeId: google.maps.MapTypeId.ROADMAP
    };

        theMap = new google.maps.Map(document.getElementById('map_canvas'), myMapOptions);

        image = 'img/point.png';

        marker = new google.maps.Marker({
            map: theMap
            draggable: false
            position: new google.maps.LatLng(54.10506, 45.10594)
            icon: image
            visible: true
        });

        boxText = document.createElement('div');

        contentString = '<div id="content-boolean">'+'<h1>Блокнотик ВК</h1>'+'<p>Россия, Саранск</p>'+'</div>';

        myOptions = {
            content: contentString
            disableAutoPan: false
            maxWidth: 200
            pixelOffset: new google.maps.Size(35, -70)
            zIndex: null
            boxStyle: {
                width: "200px"
            }
            infoBoxClearance: new google.maps.Size(1, 1)
            closeBoxURL: ""
            isHidden: false
            pane: "floatPane"
            enableEventPropagation: false
        };

        google.maps.event.addListener(marker, 'click', (e) ->
            ib.open(theMap, this);
        );

        ib = new InfoBox(myOptions);
        ib.open(theMap, marker);

    google.maps.event.addDomListener(window, 'load', initialize);


#    Animation Effects
    $sections = $('section.section[id]');
    $buttonTop = $('.button-top');
    $buttonBottom = $('.button-bottom');
    currentButtonTopState = null;

    getNextSection = () ->
        topFoldOffset = $window.scrollTop();
        bottomFoldOffset = (topFoldOffset + (windowHeight / 2));

        $current = $sections.filter(() ->
            top = $(this).offset().top;
            bottom = top + $(this).height();
            return ((top <= bottomFoldOffset && top >= topFoldOffset) || (bottom <= bottomFoldOffset && bottom >= topFoldOffset) || (top <= topFoldOffset && bottom >= bottomFoldOffset));
        );

        return $sections.eq($sections.index($current.last()) + 1);


    $('.section').on('scrollSpy:enter', ()->
         $(this).addClass('current');
         $.fn.fade = (ops) ->
            $elem = this;
            res = $.extend({ delay: 400, speed: 800 }, ops);
            i = 0;
            pause = 0;
            l = $elem.length
            while i < l
                $elem.eq(i).delay(pause).animate { 'opacity': '1' }, res.speed
                i++
                pause += res.delay;

            return $elem;
         $('#about-us.current ul.list-of-our-clients li').fade();
         $('#sb.current .f-left').animate({'left' : '0'} , 1000 , 'linear' , ()->
            $('#sb.current .f-right').animate({'right' : '0'} , 1000 , 'linear');
         );
    );

    $('.section').on('scrollSpy:exit', ()->);

    $('.section').scrollSpy();

    $('.services-provide-block h3:first-child').animate({'opacity' : '1'} , 1000 , 'linear' , ()->
        $('.services-provide-block ul li.item-1').animate({'left' : '0'} , 1000 , 'linear' , ()->
            $('.services-provide-block ul li.item-2').animate({'left' : '0'} , 1000 , 'linear' , ()->
                $('.services-provide-block ul li.item-3').animate({'left' : '0'} , 1000 , 'linear' , ()->
                    $('a.to-employee-btn').animate({'opacity' : '1'} , 1000 , 'linear');
                    $('.services-main-title').animate({'top' : '0', 'opacity' : '1'} , 700 , 'linear');
                );
            );
        );
    );

    $('.pseudo-menu').click((e)->
        e.preventDefault();
        $('#top-menu').slideToggle();
    );

    $window.on('scroll', () ->
        topState = $(this).scrollTop() > 1 ? 'block' : 'none';
        $next = getNextSection();

        if currentButtonTopState != topState
            $buttonTop.parent().css('display', topState);
            currentButtonTopState = topState;


        $buttonBottom.css('display', $next.length ? 'block' : 'none');
    ).on('resize.height', () ->
        height = $(this).height();
        if windowHeight != height
            windowHeight = height;

        sliderResize();
    ).trigger('resize.height');

    $body.on('click', '.button-top' , (e) ->
        e.preventDefault();
        scrollToElement();
    ).on('click', '.button-bottom' , (e) ->
        e.preventDefault();
        $next = getNextSection();

        if $next.length
            scrollToElement($next);
    );



#   Contact form
#    todo:поправить
    $('.contact-form').submit((e) ->
        e.preventDefault();
        $this = $(this);
        $this.find('div.error').remove();
        $this.find('.error').removeClass('error');
        button = $this.find('button');
        $('<div class="loading">Loading...</div>').insertAfter(button);
        $.post($this.attr('action'), $this.serialize(), (response) ->
            if response.error
                $('<div class="error" />').text(response.error).insertAfter(button);
            else if response.errors
                $.each(response.errors, (name, error) ->
                    $this.find('#' + name).addClass('error');
                    $('<div class="error" />').text(error).insertAfter(button);
                );
            else if response.success
                $('<div class="success" />').text(response.success).insertAfter(button);

            $this.find('.loading').remove();
        , 'json');
    );

);
