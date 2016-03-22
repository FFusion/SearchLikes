#FriendsController#

'use strict'

FriendsModule.controller 'FriendsController', ($scope, $location, $window, $state, $stateParams, params, ngTableParams, LocalStorage, RestModel, currentUser) ->

    # авторизованный пользователь
    $scope.currentUser = currentUser;

    # параметры авторизации и отображения списка пользователей
    $scope.openAccess = true;
    $scope.openTable = false;
    $scope.loading = false;

    $scope.params = $scope.params || LocalStorage.getItem('params');

    # список друзей
    $scope.getListFriends = () ->
        $scope.page = 1;
        $scope.friendsOnline = [];
        $scope.openTableOnline = false;

        if !$scope.friends
            $scope.loading = true;
            RestModel.getFriends($scope.params).then(
                (data) ->
                    console.log(data);
                    $scope.countFriends = data.response.count;
                    $scope.loading = false;
                    $scope.friends = RestModel.isWorkingFriendsObject(data);

                    $scope.openTable = if $scope.friends then true else false;
                (error) ->
                    console.log(error);
            );
        else
            $scope.openTable = true;


    # список друзей - онлайн
    $scope.getListFriendsOnlineOrDelete = (type) ->
        $scope.page = 1;
        $scope.friendsArray = RestModel.friendsOnlineOrDelete(type, $scope.friends);

        $scope.openTable = false;
        $scope.openTableOnline = if $scope.friendsArray then true else false;


    # выход
    $scope.signOff = () ->
        LocalStorage.removeAllItem();
        $scope.openAccess = false;
        $scope.openTable = false;

        $window.location = '/login'

    #получение подробной информации о пользователе
    $scope.more = (user) ->
        $state.transitionTo('user', {userId: user.id});
        LocalStorage.setItem('page',$scope.page);


    if LocalStorage.getItem('page') then $scope.getListFriends();
    $scope.page = if LocalStorage.getItem('page') then LocalStorage.getItem('page') else 1;
    $scope.pageSize = 6;
