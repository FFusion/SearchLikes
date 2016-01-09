#NotificationService#

'use strict';

MainModule.service 'Notification', ($rootScope) ->
    new class Notification

        show: (message) ->
            $rootScope.$broadcast('message:show', {type: 'notification', message: message});