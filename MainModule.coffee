#MainModule#

'use strict';

MainModule = angular.module 'MainModule', ['ngRoute', 'ui.router', 'datatables', 'ngTable', 'ngAnimate', 'ngTouch', 'FriendsModule', 'UserModule', 'WallModule', 'UserFriendsModule', 'PhotoModule', 'SelectedModule', 'ngToast'];

MainModule.constant 'vk',
    auth        : "https://oauth.vk.com/authorize"
#    clientId   : 4699380
    clientId: 3741849
    redirectUri: "http://eq.loc"
#    redirectUri: "http://vkopen.16mb.com"
    api         : "https://api.vk.com"

