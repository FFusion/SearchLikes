#UserController#

'use strict';

UserModule.controller 'UserController', ($scope, $stateParams, $location, $state, RestModel, Notification, UserModel, LocalStorage, user, params) ->

    $scope.window = window;
    $scope.params = params;

    $scope.user = RestModel.isWorkingFriendsObject(user);

    #семейное положение
    console.log($scope.user.relation);
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
#        $location.path('/user/' + user.id + '/friends');
        $state.transitionTo('user-friend', {userId: user.id});


    $scope.checkPhoto = (user) ->
#        $location.path('user/' + user.id + '/selected/photo');
        $state.transitionTo('selected', {userId: user.id, type:'photo'});

        
    console.log($scope.openAccess);