#UserController#

'use strict';

UserModule.controller 'UserController', ($scope, $stateParams, $location, $state, RestModel, Notification, UserModel, LocalStorage, user, params) ->

    $scope.window = window;
    $scope.params = params;

    $scope.user = RestModel.isWorkingFriendsObject(user);

    #семейное положение
    $scope.relationStatus = if $scope.user.relation then UserModel.relationStatus[$scope.user.relation].name else null;

    $scope.lastSeen = LocalStorage.getItem('last');

    $scope.back = () ->
        $scope.window.history.back();

    $scope.home = () ->
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