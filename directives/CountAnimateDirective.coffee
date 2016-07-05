#CountAnimateDirective#

'use strict'

MainModule.directive 'animate', ($timeout) ->

    scope      :
        count: '='

    link: (scope, element) ->
        console.log(scope);

        $timeout(()->
            $.Tween.propHooks.number = {
                get: (tween) ->
                    num = tween.elem.innerHTML.replace(/^[^\d-]+/, '');
                    return  parseFloat(num) || 0;

                set:(tween) ->
                    opts = tween.options;
                    tween.elem.innerHTML = (opts.prefix || '') + tween.now.toFixed(opts.fixed || 0) + (opts.postfix || '');
            };


            element.delay(2000).animate({number:scope.count},
                {duration: 5000}
            )
        )