#FriendsController#

'use strict'

FriendsModule.controller 'FriendsController', ($scope, $location, $window, $stateParams, params, ngTableParams, LocalStorage, RestModel) ->

    #параметры авторизации и отображения таблицы
    $scope.openAccess = true;
    $scope.openTable = false;

    $scope.params = $scope.params || LocalStorage.getItem('params');

    $scope.page = 1;
    $scope.pageSize = 10;

    $scope.getUser = (id) ->
        $location.path('user/' + id);

    # запрос на получение текущего пользователя, кто авторизовался
    RestModel.getUserById($scope.params.user_id, $scope.params).then(
        (data)->
            $scope.currentUser = data.response[0];
        (error) ->
            console.log(error);
    )

    # список друзей
    $scope.getListFriends = () ->
        $scope.friendsOnline = [];
        $scope.openTableOnline = false;

        if !$scope.friends
            RestModel.getFriends($scope.params).then(
                (data) ->
                    console.log(data);
                    $scope.countFriends = data.response.count;
                    $scope.friends = RestModel.isWorkingFriendsObject(data);

                    $scope.openTable = if $scope.friends then true else false;
                (error) ->
                    console.log(error);
            );
        else
            $scope.openTable = true;


    # список друзей - онлайн
    $scope.getListFriendsOnlineOrDelete = (type) ->
        console.log($scope.page);
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
        LocalStorage.setItem('last', user.last_seen);
