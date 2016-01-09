#NotificationDirective#

'use_strict'

MainModule.directive 'notification', ($http, $compile, $timeout) ->
    restrict: 'E',
    link: (scope, element) ->

        scope.show = (data, template) ->
            scope = angular.extend(scope, data);

            notification = $compile(template)(scope);

            $('body').append(notification);
            console.log(notification);
            notification.show();

            notification;

        scope.close = (notification) ->
            console.log(1);
            $('body').find(notification).remove();


        scope.$on('message:show', (event,data)->
            template = '/directives/views/notification.html';

            $http.get(template).success((template_get)->
                notice = scope.show(data, template_get);
                $timeout(()->
                    scope.close(notice);
                ,2000);
            )
        )