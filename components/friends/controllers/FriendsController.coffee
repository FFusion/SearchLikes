#FriendsController#

'use strict'

FriendsModule.controller 'FriendsController', ($scope, $location, $window, $timeout, $state, $stateParams, params, ngTableParams, LocalStorage, Loader, RestModel, currentUser) ->

    # авторизованный пользователь
    if currentUser
        $scope.currentUser = currentUser;
    else
        $scope.currentUser

    # параметры авторизации и отображения списка пользователей
    $scope.resultFriends = false;
    $scope.openTable = false;
    $scope.loading = false;
    tempFriendsArray = [];

    $scope.params = $scope.params || LocalStorage.getItem('params');

    #статистика по кол-ву друзей
    $scope.getStatisticAboutFriends = () ->
        if !$scope.resultFriends
            $scope.resultFriends = [];
            statisticFriends = RestModel.friendsOnlineOrDelete(null, $scope.friends);
            $scope.getListCountFriends(statisticFriends);
            $scope.loading = true;
        else
            $scope.isResultStatistic = true;
            $scope.openTable = false;
            $scope.openTableOnline = false;

    $scope.getListCountFriends = (friends) ->
        if friends.length > 25
            tempFriendsArray = friends.splice(0,25);
            $timeout(()->
                RestModel.getAllCountFriends(tempFriendsArray, $scope.params).then(
                    (data)->
                        angular.forEach(data.response, (user)->
                            $scope.resultFriends.push(user[0]);
                        )
                        $scope.getListCountFriends(friends);
                    (error)->
                        console.log(error);
                )
            ,330)
        else
            if friends.length != 0
                $timeout(()->
                    RestModel.getAllCountFriends(friends, $scope.params).then(
                        (data)->
                            angular.forEach(data.response, (user)->
                                $scope.resultFriends.push(user[0]);
                            )

                            $scope.loading = false;
                            $scope.openTable = false;
                            $scope.openTableOnline = false;
                            $scope.isResultStatistic = true;

                            $scope.resultFriends = $scope.resultFriends.sort($scope.sortable);
                            $scope.resultFriends = Loader.renderBand($scope.resultFriends);
                    )
                ,330)
            else
                console.log('dct');



    $scope.sortable = (a,b) ->
        return b.counters.friends - a.counters.friends;

    # список друзей
    $scope.getListFriends = () ->
        $scope.page = 1;
        $scope.friendsOnline = [];
        $scope.openTableOnline = false;

        if !$scope.friends
            $scope.loading = true;
            RestModel.getFriends($scope.params).then(
                (data) ->
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
        $state.transitionTo('user', {userId: user.id || user.uid});
        LocalStorage.setItem('page',$scope.page);


    if LocalStorage.getItem('page') then $scope.getListFriends();
    $scope.page = if LocalStorage.getItem('page') then LocalStorage.getItem('page') else 1;
    $scope.pageSize = 6;
