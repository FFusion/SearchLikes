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
            );
        )

