#UserFriendsController#

'use strict';

UserFriendsModule.controller 'UserFriendsController', ($scope, $location, $state, $stateParams, RestModel, LocalStorage, params) ->

    $scope.stateParams = $stateParams;
    $scope.window = window;
    $scope.params = params;

    $scope.page = 1;
    $scope.pageSize = 6;

    $scope.userId = $scope.stateParams.userId;
    $scope.loading = true;

    $scope.back = () ->
        $scope.window.history.back();

    $scope.home = () ->
        $state.transitionTo('friends');

    $scope.userFriendsArray = null;

    RestModel.getUserById($scope.userId, $scope.params).then(
        (data)->
            $scope.currentUser = data.response[0];
        (error) ->
            console.log(error);
    );

    RestModel.getFriends(params, $scope.userId).then(
        (data)->
            $scope.loading = false;
            $scope.countFriends = data.response.count;
            $scope.userFriends = RestModel.isWorkingFriendsObject(data);
            $scope.userFriendsArray = null;
        (error) ->
            console.log(error);

    )

    $scope.getListFriendsOnlineOrDelete = (type) ->
        $scope.userFriendsArray = RestModel.friendsOnlineOrDelete(type, $scope.userFriends);


    $scope.getListFriends = () ->
        $scope.userFriendsArray = null;

    $scope.more = (user) ->
        LocalStorage.setItem('last', user.last_seen);
        $state.transitionTo('user', {userId: user.id});