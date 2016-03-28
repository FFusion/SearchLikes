#MoveDirective#

'use strict'

MainModule.directive 'move', ($http, $timeout) ->

    link: (scope, element) ->

        scope.backInResult = () ->
            $timeout(()->
                $('html,body').animate({scrollTop: scope.offcet},500);
            )
            scope.lookedItems = false;

        # для мобильных устройств
        scope.showPrev = () ->
            $timeout(()->
                $('.next').click();
            )

            true;


        scope.showNext = () ->
            $timeout(()->
                $('.next').click();
            )

            true;

        $timeout(()->
            if $(window).scrollTop() >= "250" then  $("#ToTop").fadeIn("slow");
            $(window).scroll(() ->
                if $(window).scrollTop() <= "250" then $("#ToTop").fadeOut("slow") else $("#ToTop").fadeIn("slow");
            );

            if $(window).scrollTop() <= $(document).height()-"999" then $("#OnBottom").fadeIn("slow")

            $(window).scroll(() ->
                if $(window).scrollTop() >= $(document).height()-"999" then $("#OnBottom").fadeOut("slow") else $("#OnBottom").fadeIn("slow");
            );

            $("#ToTop").click(() -> $("html,body").animate({scrollTop:0},"slow"));
            $("#OnBottom").click(() -> $("html,body").animate({scrollTop:$(document).height()},"slow"));
            $("#OnBottom").click(() -> $("html,body").animate({scrollTop:$(document).height()},"slow"));
        )


