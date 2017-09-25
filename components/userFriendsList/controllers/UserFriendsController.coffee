#UserFriendsController#

'use strict';

UserFriendsModule.controller 'UserFriendsController', ($scope, $location, $state, $timeout, $stateParams, Notification, Static, RestModel, Loader, LocalStorage, params,currentUser) ->

    $scope.stateParams = $stateParams;
    $scope.window = window;
    $scope.params = params;
    Static.params = params;
    $scope.hideUsers = [];

    $scope.page = 1;
    $scope.pageSize = 50;

    $scope.userId = $scope.stateParams.userId;
    $scope.currentUser = currentUser;

    $scope.loading = true;
    $scope.resultUserFriends = false;

    $scope.back = () ->
        $scope.window.history.back();

    $scope.home = () ->
        $state.transitionTo('friends');

    $scope.userFriendsArray = null;


    # загружаем список друзей
    RestModel.getFriends(params, $scope.userId).then(
        (data)->
            $scope.loading = false;
            $scope.countFriends = data.response.count;
            $scope.userFriends = RestModel.isWorkingFriendsObject(data);
            $scope.userFriendsArray = null;
        (error) ->
            Notification.error(error);

    )


    $scope.getFriendsWhoHideYour = () ->
        $scope.loading = true;
        count = $scope.userFriends.length;
        listFriends = angular.copy($scope.userFriends);

        listFriends = RestModel.friendsOnlineOrDelete(null,listFriends);

        Static.getHideFriendsList(count, listFriends, $scope.userId, []).then(
            (result) ->
                $scope.resultHide = result;
                if $scope.resultHide.length == 0
                    Notification.show('Скорее всего пользователя никто не скрывает');
                    $scope.loading = false;
                else
                    Static.getFriends($scope.resultHide, []).then(
                        (users) ->
                            $scope.loading = false;
                            $scope.hideUsers = users;
                            $scope.openTableOnline = false;
                            $scope.openTable = false;
                        (error)->
                            Notification.error(error);
                    )
            (error) ->
                Notification.error(error);
        );


    $scope.getListFriendsOnlineOrDelete = (type) ->
        $scope.hideUsers = [];
        $scope.userFriendsArray = RestModel.friendsOnlineOrDelete(type, $scope.userFriends);


    $scope.getListFriends = () ->
        $scope.hideUsers = [];
        $scope.userFriendsArray = null;

    $scope.more = (user) ->
        LocalStorage.setItem('last', user.last_seen);
        $state.transitionTo('user', {userId: user.id || user.uid});

    $scope.getStatisticPage = () ->
        $state.transitionTo('statistics', {userId:$scope.userId});
