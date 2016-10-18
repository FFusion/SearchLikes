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

        .state('login',
            url:'/login',
            controller:'MainController',
            templateUrl:'components/login/views/login.html'
        )

        .state('friends',
            url         : '/friends',
            controller  : 'FriendsController',
            templateUrl : 'components/friends/views/friends.html',
            resolve     :
                params: (LocalStorage) -> LocalStorage.getItem('params')
                currentUser: (RestModel, params, $q) ->
                    deffered = $q.defer();
                    if params
                        RestModel.getUserById(params.user_id, params).then(
                            (data) ->
                                deffered.resolve(data.response[0]);
                            (error) ->
                                deffered.reject(error);
                        )
                        deffered.promise;
                    else
                        false

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

        .state('commentsPhoto',
            url         : '/user/:userId/commentsPhoto',
            controller  : 'CommentsPhotoController',
            templateUrl : 'components/commentsPhoto/views/commentsPhoto.html',
            resolve     :
                params: (LocalStorage) -> LocalStorage.getItem('params');
                currentUser: (RestModel, $stateParams,params) ->  RestModel.getUserById($stateParams.userId,params);
                friends: (RestModel, $stateParams, params, currentUser) -> RestModel.getFriends(params, $stateParams.userId);
        )

        .state('commentsGroup',
            url         : '/user/:userId/commentsGroup',
            controller  : 'CommentsGroupController',
            templateUrl : 'components/commentsGroup/views/commentsGroup.html',
            resolve     :
                params: (LocalStorage) -> LocalStorage.getItem('params');
                currentUser: (RestModel, $stateParams,params) ->  RestModel.getUserById($stateParams.userId,params);
        )

        .state('statistics',
            url         : '/statisticsFriends/:userId',
            controller  : 'StatisticsFriendsController',
            templateUrl : 'components/statisticFriends/views/index.html',
            resolve     :
                params: (LocalStorage) -> LocalStorage.getItem('params');
                currentUser: (RestModel, $stateParams,params) ->  RestModel.moreInfo($stateParams.userId,params);
                friends: (RestModel, $stateParams, params, currentUser) -> RestModel.getFriends(params, $stateParams.userId);
        )

        .state('groups',
            url         : '/groups',
            controller  : 'GroupsController',
            templateUrl : 'components/groups/views/group.html',
            resolve     :
                params: (LocalStorage) -> LocalStorage.getItem('params');
                groups: (RestModel, params) -> RestModel.getGroupCurentUserAdmin(params.user_id, params);

        )
        .state('groupContent',
            url         : '/group/:groupId',
            controller  : 'GroupContentController',
            templateUrl : 'components/groupContent/views/content.html',
            resolve     :
                params: (LocalStorage) -> LocalStorage.getItem('params');
                group: ($stateParams, RestModel, params) -> RestModel.getGroupById($stateParams.groupId, params);
#                usersGroups: (RestModel, params, group) -> RestModel.getMemeberInGroup(group.response[0].id, params);

        )
        .state('groupPostsLikes',
            url         : '/group/:groupId/posts/:userId',
            controller  : 'PostWithLikesController',
            templateUrl : 'components/groupContent/views/posts.html',
            resolve     :
                params: (LocalStorage) -> LocalStorage.getItem('params');
        )

        .state('global',
            url         : '/global',
            controller  : 'GlobalStatController',
            templateUrl : 'components/migrations/views/global.html',
            resolve     :
                params: (LocalStorage) -> LocalStorage.getItem('params');
        )

        .state('migrations',
            url         : '/global/migrations',
            controller  : 'MigrationsController',
            templateUrl : 'components/migrations/views/migrations.html',
            resolve     :
                params: (LocalStorage) -> LocalStorage.getItem('params');
        )

        .state('relations',
            url         : '/global/relations',
            controller  : 'RelationsController',
            templateUrl : 'components/migrations/views/relations.html',
            resolve     :
                params: (LocalStorage) -> LocalStorage.getItem('params');
                man: (RestModel, params) -> RestModel.getRelationsForUser(params, 1);
                woman: (RestModel, params, man) -> RestModel.getRelationsForUser(params, 2);
                notMarried: (RestModel, params, woman, $timeout) ->
                    $timeout(
                        ()->
                            RestModel.getRelationsForUser(params, null, 1)
                        ,333);
                meeting: (RestModel, params, notMarried,$timeout) ->
                    $timeout(
                        ()->
                            RestModel.getRelationsForUser(params, null, 2);
                    ,333);
                engaged: (RestModel, params, meeting,$timeout) ->
                    $timeout(
                        ()->
                            RestModel.getRelationsForUser(params, null, 3);
                        ,333);
                married: (RestModel, params, engaged,$timeout) ->
                    $timeout(
                        ()->
                            RestModel.getRelationsForUser(params, null, 4);
                        ,333);
                complicated: (RestModel, params, married, $timeout) ->
                    $timeout(
                        ()->
                            RestModel.getRelationsForUser(params, null, 5);
                        ,333);
                active: (RestModel, params, complicated, $timeout) ->
                    $timeout(
                        ()->
                            RestModel.getRelationsForUser(params, null, 6);
                        ,333);
                loved: (RestModel, params, active, $timeout) ->
                    $timeout(
                        ()->
                            RestModel.getRelationsForUser(params, null, 7);
                        ,333);

        )



        $urlRouterProvider.otherwise('/login');
    ]

MainModule.run(($rootScope, $state)->

    $rootScope.$on('$stateChangeSuccess', ()->
        $('body').scrollTop(0);
    )
)

