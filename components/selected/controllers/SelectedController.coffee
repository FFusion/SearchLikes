#SelectedController#

'use strict'

SelectedModule.controller 'SelectedController', ($scope, $stateParams, $location, $timeout, RestModel, params, currentUser) ->

    $scope.params = params;
    $scope.window = window;
    $scope.stateParams = $stateParams;
    $scope.loading = true;

    $scope.userId = $scope.stateParams.userId;
    $scope.currentUser = currentUser;

    #тип стена или фото
    $scope.type = $scope.stateParams.type;

    $scope.selected = null;

    $scope.page = 1;
    $scope.pageSize = 7;


    # загружаем список друзей
    RestModel.getFriends(params, $scope.userId).then(
        (data)->
            $scope.loading = false;
            $scope.countFriends = data.response.count;
            $scope.userFriends = RestModel.isWorkingFriendsObject(data);
        (error) ->
            console.log(error);

    )

    $scope.back = () ->
        $scope.window.history.back();

    $scope.isSelected = (selected) ->
        if $scope.selected isnt null && selected == $scope.selected
            $scope.selected = null
        else
            $scope.selected = selected;

    $scope.selectUserNext = () ->
        $location.path('user/' + $scope.userId + '/selected/' + $scope.selected.id + '/' + $scope.type);
