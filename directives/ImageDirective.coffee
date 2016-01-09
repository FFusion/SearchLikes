#ImageDirective#

'use strict'

MainModule.directive 'image', ($http, $compile) ->

    link: (scope, element) ->

        if scope.openBigBlade
            template = '/directives/views/image.html';

            $http.get(template).success((data)->
                image =  $compile(data)(scope);
                element.append(image);
            )
