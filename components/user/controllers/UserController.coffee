#UserController#

'use strict';

UserModule.controller 'UserController', ($scope, $stateParams, $location, RestModel, Notification, LocalStorage, user, params) ->

    $scope.window = window;
    $scope.params = params;
    $scope.user = RestModel.isWorkingFriendsObject(user);
    console.log(user);

    $scope.lastSeen = LocalStorage.getItem('last');

    $scope.back = () ->
        $scope.window.history.back();

    $scope.home = () ->
        $location.path('/friends');

    $scope.checkWall = (user) ->
        $location.path('/user/' + user.id + '/selected/wall');


    $scope.getUserFriends = (user) ->
        $location.path('/user/' + user.id + '/friends');


    $scope.checkPhoto = (user) ->
        $location.path('user/' + user.id + '/selected/photo');

