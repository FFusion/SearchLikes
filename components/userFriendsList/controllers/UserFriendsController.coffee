#UserFriendsController#

'use strict';

UserFriendsModule.controller 'UserFriendsController', ($scope, $location, $state, $timeout, $stateParams, RestModel, Loader, LocalStorage, params,currentUser) ->

    $scope.stateParams = $stateParams;
    $scope.window = window;
    $scope.params = params;

    $scope.page = 1;
    $scope.pageSize = 6;

    $scope.userId = $scope.stateParams.userId;
    $scope.currentUser = currentUser;

    $scope.loading = true;
    $scope.resultUserFriends = false;
    tempFriendsArray = [];

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
            console.log(error);

    )

    $scope.getListFriendsOnlineOrDelete = (type) ->
        $scope.userFriendsArray = RestModel.friendsOnlineOrDelete(type, $scope.userFriends);
        $scope.isResultUserStatistic = false;


    $scope.getListFriends = () ->
        $scope.userFriendsArray = null;
        $scope.isResultUserStatistic = false;

    $scope.more = (user) ->
        LocalStorage.setItem('last', user.last_seen);
        $state.transitionTo('user', {userId: user.id || user.uid});

    #статистика по кол-ву друзей
    $scope.getStatisticAboutUserFriends = () ->
        if !$scope.resultUserFriends
            $scope.resultUserFriends = [];
            statisticFriends = RestModel.friendsOnlineOrDelete(null, $scope.userFriends);
            $scope.getListCountFriends(statisticFriends);
            $scope.loading = true;
        else
            $scope.isResultUserStatistic = true;
            $scope.userFriendsArray = null;

    $scope.getListCountFriends = (friends) ->
        if friends.length > 25
            tempFriendsArray = friends.splice(0,25);
            $timeout(()->
                RestModel.getAllCountFriends(tempFriendsArray, $scope.params).then(
                    (data)->
                        angular.forEach(data.response, (user)->
                            $scope.resultUserFriends.push(user[0]);
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
                                $scope.resultUserFriends.push(user[0]);
                            )

                            $scope.loading = false;
                            $scope.openTable = false;
                            $scope.openTableOnline = false;
                            $scope.isResultUserStatistic = true;

                            $scope.resultUserFriends = $scope.resultUserFriends.sort($scope.sortable);
                            $scope.resultUserFriends = Loader.renderBand($scope.resultUserFriends);
                    )
                ,330)
            else
                console.log('dct');



    $scope.sortable = (a,b) ->
        return b.counters.friends - a.counters.friends;
