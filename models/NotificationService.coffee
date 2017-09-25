#NotificationService#

'use strict';

MainModule.service 'Notification', ($rootScope, $q, ngToast) ->
    new class Notification

        success: (message) ->
            ngToast.success({
                content: message
                timeout:	5000
            });

        error: (message) ->
            ngToast.danger({
                content: message
                timeout:	5000
            });

        show: (message) ->
            ngToast.info({
                content: message
                timeout:	5000
            });

