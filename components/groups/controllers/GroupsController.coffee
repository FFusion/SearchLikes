#GroupsController#

'use strict';

GroupsUserModule.controller 'GroupsController', ($scope, $stateParams, $state, $timeout, $location, RestModel, Notification, LocalStorage, params, groups) ->

    $scope.window = window;
    $scope.params = params;
    $scope.stateParams = $stateParams;
    $scope.loading = false;
    $scope.page = 1;
    $scope.pageSize = 4;

    $scope.otherGroup = {};



    $scope.groups = groups.response.items;


    $scope.returnListFriends = () ->
        $state.transitionTo('friends');

    $scope.getMoreinfo = (group) ->
        $state.transitionTo('groupContent', {groupId:group.id});


    $scope.searchGroup = () ->
        if $scope.otherGroup.id
            RestModel.getGroupById($scope.otherGroup.id, $scope.params).then((data)->
                $scope.groups = data.response;
            )