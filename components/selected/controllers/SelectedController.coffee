#SelectedController#

'use strict'

SelectedModule.controller 'SelectedController', ($scope, $stateParams, $location, RestModel, params) ->

    $scope.params = params;
    $scope.window = window;
    $scope.stateParams = $stateParams;

    $scope.userId = $scope.stateParams.userId;
    #тип стена или фото
    $scope.type = $scope.stateParams.type;

    $scope.selected = null;

    $scope.page = 1;
    $scope.pageSize = 8;

    $scope.back = () ->
        $scope.window.history.back();

    RestModel.getUserById($scope.userId, $scope.params).then(
        (data)->
            $scope.currentUser = data.response[0];
        (error) ->
            console.log(error);
    );

    RestModel.getFriends(params, $scope.userId).then(
        (data)->
            $scope.countFriends = data.response.count;
            $scope.userFriends = RestModel.isWorkingFriendsObject(data);
        (error) ->
            console.log(error);

    )

    $scope.isSelected = (selected) ->
        if $scope.selected isnt null && selected == $scope.selected
            $scope.selected = null
        else
            $scope.selected = selected;

    $scope.selectUserNext = () ->
        $location.path('user/' + $scope.userId + '/selected/' + $scope.selected.id + '/' + $scope.type);
