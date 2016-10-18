#MainModule#

'use strict';

MainModule = angular.module 'MainModule', ['ngRoute', 'ui.router', 'datatables', 'ngTable', 'ngAnimate', 'ngTouch', 'FriendsModule', 'UserModule', 'WallModule', 'UserFriendsModule', 'PhotoModule', 'SelectedModule', 'ProcessingPhotoModule','ProcessingWallModule','CommentsPhotoModule','StatisticsFriendsModule','GroupsUserModule','GroupContentModule', 'MigrationsModule','ngToast', 'googlechart', 'CommentsGroupModule'];
MainModule.constant 'vk',
    auth        : "https://oauth.vk.com/authorize"
    clientId: 3741849
    redirectUri: "http://eq.loc"
    api         : "https://api.vk.com"

