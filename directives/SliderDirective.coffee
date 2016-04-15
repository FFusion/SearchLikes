#SliderDirective#

'use strict'

MainModule.directive 'slide', ($timeout) ->

    link: (scope, element) ->

        $timeout(()->
            $(".rslides").responsiveSlides(
                auto: false,
                speed: 500,
                nav: true,
                prevText: "Назад",
                nextText: "Далее",
                maxwidth: 500
                before: () ->
                    scope.$parent.onlyCurrent = true;
            );

            $('.next').click(()->
                scope.$parent.onlyCurrent = true;
            )

            $('.prev').click(()->
                scope.$parent.onlyCurrent = true;
            )
        )

