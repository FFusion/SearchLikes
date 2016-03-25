#config#

'use strict';

MainModule.config ['$httpProvider', '$locationProvider', '$stateProvider', '$urlRouterProvider', '$sceDelegateProvider'
    ($httpProvider, $locationProvider, $stateProvider, $urlRouterProvider, $sceDelegateProvider) ->
        $httpProvider.defaults.useXDomain = true;

        delete $httpProvider.defaults.headers.common['X-Requested-With'];

        $httpProvider.defaults.headers.common =
            'Accept': 'application/hal+json'

        $httpProvider.defaults.headers.post =
            'Content-Type': 'application/json'


        # включаем html5-режим работы с урлами
        $locationProvider.html5Mode(true);
        $locationProvider.hashPrefix('!');

        $sceDelegateProvider.resourceUrlWhitelist(['**']);

#        $routeProvider.when('/login',
#            controller: 'MainController',
#            templateUrl: 'index.html'
#        )
#
#        $routeProvider.when('/project',
#            controller: 'ProjectController'
#            templateUrl: 'components/views/project.html'
#            resolve:
#                params: (LocalStorage) -> LocalStorage.getItem('params');
#        )

        $stateProvider

        .state('friends',
            url         : '/friends',
            controller  : 'FriendsController',
            templateUrl : 'components/friends/views/friends.html',
            resolve     :
                params: (LocalStorage) -> LocalStorage.getItem('params')
                currentUser: (RestModel, params, $q) ->
                    deffered = $q.defer();
                    RestModel.getUserById(params.user_id, params).then(
                        (data) ->
                            deffered.resolve(data.response[0]);
                        (error) ->
                            deffered.reject(error);
                    )
                    deffered.promise;
        )

        .state('user',
            url         : '/user/:userId',
            controller  : 'UserController',
            templateUrl : 'components/user/views/user.html',
            resolve     :
                params: (LocalStorage) -> LocalStorage.getItem('params');
                user: ($stateParams, params, RestModel) -> RestModel.moreInfo($stateParams.userId, params);
        )

        .state('wall',
            url         : '/user/:userId/selected/:selectedId/wall',
            controller  : 'WallController',
            templateUrl : 'components/wall/views/wall.html',
            resolve     :
                params: (LocalStorage) -> LocalStorage.getItem('params');
                user: ($stateParams, params, RestModel) -> RestModel.moreInfo($stateParams.userId, params);
                userSearchFor: ($stateParams, params, RestModel,$q) ->
                    deffered = $q.defer();
                    RestModel.moreInfo($stateParams.selectedId, params).then(
                        (data)->
                            deffered.resolve(data.response[0])
                        (error)->
                            deffered.reject(error);
                    )
                    deffered.promise;
        )

        .state('photo',
            url         : '/user/:userId/selected/:selectedId/photo',
            controller  : 'PhotoController',
            templateUrl : 'components/photo/views/photo.html',
            resolve     :
                params: (LocalStorage) -> LocalStorage.getItem('params');
                user: ($stateParams, params, RestModel) -> RestModel.moreInfo($stateParams.userId, params);
                userSearchFor: ($stateParams, params, RestModel,$q) ->
                    deffered = $q.defer();
                    RestModel.moreInfo($stateParams.selectedId, params).then(
                        (data)->
                            deffered.resolve(data.response[0])
                        (error)->
                            deffered.reject(error);
                    )
                    deffered.promise;
        )

        .state('user-friend',
            url         : '/user/:userId/friends',
            controller  : 'UserFriendsController',
            templateUrl : 'components/userFriendsList/views/userFriendList.html',
            resolve     :
                params: (LocalStorage) -> LocalStorage.getItem('params');
                currentUser: (RestModel, $stateParams, params, $q) ->
                    deffered = $q.defer();
                    RestModel.getUserById($stateParams.userId, params).then(
                        (data) ->
                            deffered.resolve(data.response[0]);
                        (error) ->
                            deffered.reject(error);
                    )
                    deffered.promise;
        )

        .state('selected',
            url         : '/user/:userId/selected/:type',
            controller  : 'SelectedController',
            templateUrl : 'components/selected/views/selected.html',
            resolve     :
                params: (LocalStorage) -> LocalStorage.getItem('params');
                currentUser: (RestModel, $stateParams, params, $q) ->
                    deffered = $q.defer();
                    RestModel.getUserById($stateParams.userId, params).then(
                        (data) ->
                            deffered.resolve(data.response[0]);
                        (error) ->
                            deffered.reject(error);
                    )
                    deffered.promise;
        )

        .state('processingPhoto',
            url         : '/user/:userId/processingPhoto',
            controller  : 'ProcessingPhotoController',
            templateUrl : 'components/processingPhoto/views/processingPhoto.html',
            resolve     :
                params: (LocalStorage) -> LocalStorage.getItem('params');
                currentUser: (RestModel, $stateParams,params) ->  RestModel.getUserById($stateParams.userId,params);
                friends: (RestModel, $stateParams, params, currentUser) -> RestModel.getFriends(params, $stateParams.userId);
            )

        .state('processingWall',
            url         : '/user/:userId/processingWall',
            controller  : 'ProcessingWallController',
            templateUrl : 'components/processingWall/views/processingWall.html',
            resolve     :
                params: (LocalStorage) -> LocalStorage.getItem('params');
                currentUser: (RestModel, $stateParams,params) ->  RestModel.getUserById($stateParams.userId,params);
                friends: (RestModel, $stateParams, params, currentUser) -> RestModel.getFriends(params, $stateParams.userId);
            )


        $urlRouterProvider.otherwise('/login');
    ]

MainModule.run(($rootScope, $state)->

    $rootScope.$on('$stateChangeSuccess', ()->
        $('body').scrollTop(0);
    )
)

