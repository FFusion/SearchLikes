// Generated by CoffeeScript 1.7.1
'use strict';
MainModule.config([
  '$httpProvider', '$locationProvider', '$stateProvider', '$urlRouterProvider', '$sceDelegateProvider', function($httpProvider, $locationProvider, $stateProvider, $urlRouterProvider, $sceDelegateProvider) {
    $httpProvider.defaults.useXDomain = true;
    delete $httpProvider.defaults.headers.common['X-Requested-With'];
    $httpProvider.defaults.headers.common = {
      'Accept': 'application/hal+json'
    };
    $httpProvider.defaults.headers.post = {
      'Content-Type': 'application/json'
    };
    $locationProvider.html5Mode(true);
    $locationProvider.hashPrefix('!');
    $sceDelegateProvider.resourceUrlWhitelist(['**']);
    $stateProvider.state('login', {
      url: '/login',
      controller: 'MainController',
      templateUrl: 'components/login/views/login.html'
    }).state('friends', {
      url: '/friends',
      controller: 'FriendsController',
      templateUrl: 'components/friends/views/friends.html',
      resolve: {
        params: function(LocalStorage) {
          return LocalStorage.getItem('params');
        },
        currentUser: function(RestModel, params, $q) {
          var deffered;
          deffered = $q.defer();
          if (params) {
            RestModel.getUserById(params.user_id, params).then(function(data) {
              return deffered.resolve(data.response[0]);
            }, function(error) {
              return deffered.reject(error);
            });
            return deffered.promise;
          } else {
            return false;
          }
        }
      }
    }).state('user', {
      url: '/user/:userId',
      controller: 'UserController',
      templateUrl: 'components/user/views/user.html',
      resolve: {
        params: function(LocalStorage) {
          return LocalStorage.getItem('params');
        },
        user: function($stateParams, params, RestModel) {
          return RestModel.moreInfo($stateParams.userId, params);
        }
      }
    }).state('wall', {
      url: '/user/:userId/selected/:selectedId/wall',
      controller: 'WallController',
      templateUrl: 'components/wall/views/wall.html',
      resolve: {
        params: function(LocalStorage) {
          return LocalStorage.getItem('params');
        },
        user: function($stateParams, params, RestModel) {
          return RestModel.moreInfo($stateParams.userId, params);
        },
        userSearchFor: function($stateParams, params, RestModel, $q) {
          var deffered;
          deffered = $q.defer();
          RestModel.moreInfo($stateParams.selectedId, params).then(function(data) {
            return deffered.resolve(data.response[0]);
          }, function(error) {
            return deffered.reject(error);
          });
          return deffered.promise;
        }
      }
    }).state('photo', {
      url: '/user/:userId/selected/:selectedId/photo',
      controller: 'PhotoController',
      templateUrl: 'components/photo/views/photo.html',
      resolve: {
        params: function(LocalStorage) {
          return LocalStorage.getItem('params');
        },
        user: function($stateParams, params, RestModel) {
          return RestModel.moreInfo($stateParams.userId, params);
        },
        userSearchFor: function($stateParams, params, RestModel, $q) {
          var deffered;
          deffered = $q.defer();
          RestModel.moreInfo($stateParams.selectedId, params).then(function(data) {
            return deffered.resolve(data.response[0]);
          }, function(error) {
            return deffered.reject(error);
          });
          return deffered.promise;
        }
      }
    }).state('user-friend', {
      url: '/user/:userId/friends',
      controller: 'UserFriendsController',
      templateUrl: 'components/userFriendsList/views/userFriendList.html',
      resolve: {
        params: function(LocalStorage) {
          return LocalStorage.getItem('params');
        },
        currentUser: function(RestModel, $stateParams, params, $q) {
          var deffered;
          deffered = $q.defer();
          RestModel.getUserById($stateParams.userId, params).then(function(data) {
            return deffered.resolve(data.response[0]);
          }, function(error) {
            return deffered.reject(error);
          });
          return deffered.promise;
        }
      }
    }).state('selected', {
      url: '/user/:userId/selected/:type',
      controller: 'SelectedController',
      templateUrl: 'components/selected/views/selected.html',
      resolve: {
        params: function(LocalStorage) {
          return LocalStorage.getItem('params');
        },
        currentUser: function(RestModel, $stateParams, params, $q) {
          var deffered;
          deffered = $q.defer();
          RestModel.getUserById($stateParams.userId, params).then(function(data) {
            return deffered.resolve(data.response[0]);
          }, function(error) {
            return deffered.reject(error);
          });
          return deffered.promise;
        }
      }
    }).state('processingPhoto', {
      url: '/user/:userId/processingPhoto',
      controller: 'ProcessingPhotoController',
      templateUrl: 'components/processingPhoto/views/processingPhoto.html',
      resolve: {
        params: function(LocalStorage) {
          return LocalStorage.getItem('params');
        },
        currentUser: function(RestModel, $stateParams, params) {
          return RestModel.getUserById($stateParams.userId, params);
        },
        friends: function(RestModel, $stateParams, params, currentUser) {
          return RestModel.getFriends(params, $stateParams.userId);
        }
      }
    }).state('processingWall', {
      url: '/user/:userId/processingWall',
      controller: 'ProcessingWallController',
      templateUrl: 'components/processingWall/views/processingWall.html',
      resolve: {
        params: function(LocalStorage) {
          return LocalStorage.getItem('params');
        },
        currentUser: function(RestModel, $stateParams, params) {
          return RestModel.getUserById($stateParams.userId, params);
        },
        friends: function(RestModel, $stateParams, params, currentUser) {
          return RestModel.getFriends(params, $stateParams.userId);
        }
      }
    }).state('commentsPhoto', {
      url: '/user/:userId/commentsPhoto',
      controller: 'CommentsPhotoController',
      templateUrl: 'components/commentsPhoto/views/commentsPhoto.html',
      resolve: {
        params: function(LocalStorage) {
          return LocalStorage.getItem('params');
        },
        currentUser: function(RestModel, $stateParams, params) {
          return RestModel.getUserById($stateParams.userId, params);
        },
        friends: function(RestModel, $stateParams, params, currentUser) {
          return RestModel.getFriends(params, $stateParams.userId);
        }
      }
    }).state('commentsGroup', {
      url: '/user/:userId/commentsGroup',
      controller: 'CommentsGroupController',
      templateUrl: 'components/commentsGroup/views/commentsGroup.html',
      resolve: {
        params: function(LocalStorage) {
          return LocalStorage.getItem('params');
        },
        currentUser: function(RestModel, $stateParams, params) {
          return RestModel.getUserById($stateParams.userId, params);
        }
      }
    }).state('statistics', {
      url: '/statisticsFriends/:userId',
      controller: 'StatisticsFriendsController',
      templateUrl: 'components/statisticFriends/views/index.html',
      resolve: {
        params: function(LocalStorage) {
          return LocalStorage.getItem('params');
        },
        currentUser: function(RestModel, $stateParams, params) {
          return RestModel.moreInfo($stateParams.userId, params);
        },
        friends: function(RestModel, $stateParams, params, currentUser) {
          return RestModel.getFriends(params, $stateParams.userId);
        }
      }
    }).state('groups', {
      url: '/groups',
      controller: 'GroupsController',
      templateUrl: 'components/groups/views/group.html',
      resolve: {
        params: function(LocalStorage) {
          return LocalStorage.getItem('params');
        },
        groups: function(RestModel, params) {
          return RestModel.getGroupCurentUserAdmin(params.user_id, params);
        }
      }
    }).state('groupContent', {
      url: '/group/:groupId',
      controller: 'GroupContentController',
      templateUrl: 'components/groupContent/views/content.html',
      resolve: {
        params: function(LocalStorage) {
          return LocalStorage.getItem('params');
        },
        group: function($stateParams, RestModel, params) {
          return RestModel.getGroupById($stateParams.groupId, params);
        }
      }
    }).state('groupPostsLikes', {
      url: '/group/:groupId/posts/:userId',
      controller: 'PostWithLikesController',
      templateUrl: 'components/groupContent/views/posts.html',
      resolve: {
        params: function(LocalStorage) {
          return LocalStorage.getItem('params');
        }
      }
    }).state('global', {
      url: '/global',
      controller: 'GlobalStatController',
      templateUrl: 'components/migrations/views/global.html',
      resolve: {
        params: function(LocalStorage) {
          return LocalStorage.getItem('params');
        }
      }
    }).state('migrations', {
      url: '/global/migrations',
      controller: 'MigrationsController',
      templateUrl: 'components/migrations/views/migrations.html',
      resolve: {
        params: function(LocalStorage) {
          return LocalStorage.getItem('params');
        }
      }
    }).state('relations', {
      url: '/global/relations',
      controller: 'RelationsController',
      templateUrl: 'components/migrations/views/relations.html',
      resolve: {
        params: function(LocalStorage) {
          return LocalStorage.getItem('params');
        },
        man: function(RestModel, params) {
          return RestModel.getRelationsForUser(params, 1);
        },
        woman: function(RestModel, params, man) {
          return RestModel.getRelationsForUser(params, 2);
        },
        notMarried: function(RestModel, params, woman, $timeout) {
          return $timeout(function() {
            return RestModel.getRelationsForUser(params, null, 1);
          }, 333);
        },
        meeting: function(RestModel, params, notMarried, $timeout) {
          return $timeout(function() {
            return RestModel.getRelationsForUser(params, null, 2);
          }, 333);
        },
        engaged: function(RestModel, params, meeting, $timeout) {
          return $timeout(function() {
            return RestModel.getRelationsForUser(params, null, 3);
          }, 333);
        },
        married: function(RestModel, params, engaged, $timeout) {
          return $timeout(function() {
            return RestModel.getRelationsForUser(params, null, 4);
          }, 333);
        },
        complicated: function(RestModel, params, married, $timeout) {
          return $timeout(function() {
            return RestModel.getRelationsForUser(params, null, 5);
          }, 333);
        },
        active: function(RestModel, params, complicated, $timeout) {
          return $timeout(function() {
            return RestModel.getRelationsForUser(params, null, 6);
          }, 333);
        },
        loved: function(RestModel, params, active, $timeout) {
          return $timeout(function() {
            return RestModel.getRelationsForUser(params, null, 7);
          }, 333);
        }
      }
    }).state('analysisFriends', {
      url: '/analysis/friends/:userId',
      controller: 'AnalysisFriendsController',
      templateUrl: 'components/statisticFriends/views/analysis.html',
      resolve: {
        params: function(LocalStorage) {
          return LocalStorage.getItem('params');
        },
        friends: function(RestModel, params, $stateParams) {
          return RestModel.getListFriendsForAnalisys($stateParams.userId, params);
        },
        currentUser: function(RestModel, $stateParams, params) {
          return RestModel.moreInfo($stateParams.userId, params);
        }
      }
    });
    return $urlRouterProvider.otherwise('/login');
  }
]);

MainModule.run(function($rootScope, $state) {
  return $rootScope.$on('$stateChangeSuccess', function() {
    return $('body').scrollTop(0);
  });
});

//# sourceMappingURL=config.map
