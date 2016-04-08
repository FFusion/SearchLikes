#TabsDirective#

'use strict'

MainModule.directive 'tabs', ($timeout) ->

    link: (scope, element) ->

        $timeout(()->
            element.easyResponsiveTabs();
        )