#FriendsController#

'use strict'

FriendsModule.controller 'FriendsController', ($scope, $location, $window, $state, $stateParams, params, ngTableParams, LocalStorage, RestModel) ->

    #параметры авторизации и отображения таблицы
    $scope.openAccess = true;
    $scope.openTable = false;

    $scope.params = $scope.params || LocalStorage.getItem('params');


#    $scope.getUser = (id) ->
#        $location.path('user/' + id);

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
        $state.transitionTo('user', {userId: user.id});
        LocalStorage.setItem('page',$scope.page);


    if LocalStorage.getItem('page') then $scope.getListFriends();
    $scope.page = if LocalStorage.getItem('page') then LocalStorage.getItem('page') else 1;
    $scope.pageSize = 6;
