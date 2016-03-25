#UserController#

'use strict';

UserModule.controller 'UserController', ($scope, $stateParams, $location, $state, RestModel, Notification, UserModel, LocalStorage, user, params) ->

    $scope.window = window;
    $scope.params = params;

    $scope.user = RestModel.isWorkingFriendsObject(user);

    #семейное положение
    $scope.relationStatus = UserModel.getRelationStatus($scope.user);

    $scope.lastSeen = LocalStorage.getItem('last');

    $scope.back = () ->
        $scope.window.history.back();

    $scope.home = () ->
        if LocalStorage.getItem('page') then LocalStorage.removeItem('page');
        $state.transitionTo('friends');

    $scope.checkWall = (user) ->
        $state.transitionTo('selected', {userId: user.id, type:'wall'});


    $scope.getUserFriends = (user) ->
        $state.transitionTo('user-friend', {userId: user.id});


    $scope.checkPhotoOne = (user) ->
        $state.transitionTo('selected', {userId: user.id, type:'photo'});

    $scope.checkPhotoAll = (user) ->
        $state.transitionTo('processingPhoto', {userId: user.id});

    $scope.checkWallAll = (user) ->
        $state.transitionTo('processingWall', {userId: user.id});