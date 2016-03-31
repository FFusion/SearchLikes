#NotificationService#

'use strict';

MainModule.service 'Notification', ($rootScope, $q, ngToast) ->
    new class Notification

        success: (message) ->
            ngToast.success({
                content: message
                timeout:	3000
            });

        error: (message) ->
            ngToast.danger({
                content: message
                timeout:	3000
            });

        show: (message) ->
            ngToast.info({
                content: message
                timeout:	3000
            });