#StatisticsFriendsController#

'use strict'

StatisticsFriendsModule.controller 'StatisticsFriendsController', ($scope, $stateParams, $state, $location, $timeout, RestModel, Loader, params, currentUser, friends) ->

    $scope.params = params;
    $scope.currentUser = currentUser.response[0];
    $scope.friends = friends.response.items;
    $scope.offset = 0;

    $scope.selectedStat = true;

    $scope.home = () ->
        $state.transitionTo('friends');

    $scope.choosing = () ->
        $scope.selectedStat = true;

    #статистика по кол-ву друзей
    $scope.getStatisticAboutFriends = () ->
        if !$scope.resultFriends
            $scope.resultFriends = [];
            statisticFriends = RestModel.friendsOnlineOrDelete(null, $scope.friends);
            $scope.getListCountFriends(statisticFriends);
            $scope.loading = true;
        else
            $scope.selectedStat = false;
            $scope.firstStat = true;
            $scope.secondStat = false;

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
                            $scope.selectedStat = false;
                            $scope.firstStat = true;

                            $scope.resultFriends = $scope.resultFriends.sort($scope.sortable);
                            $scope.resultFriends = Loader.renderBand($scope.resultFriends);
                    )
                ,330)
            else
                console.log('dct');



    $scope.sortable = (a,b) ->
        return b.counters.friends - a.counters.friends;


    # статистика по активности
    $scope.getStatActiveUser = () ->
        $scope.userPhotos = [];
        $scope.userLikes = [];

        if !$scope.resultStatSecond
            $scope.resultStatSecond = [];
            $scope.arrayIdFriends = {};
            statisticFriends = RestModel.friendsOnlineOrDelete(null, $scope.friends);
            angular.forEach(statisticFriends, (user)->
                $scope.arrayIdFriends[user.id] = user;
                $scope.arrayIdFriends[user.id].count = 0;
            )
            $scope.getActiveScan($scope.currentUser.counters.photos);
            $scope.loading = true;
        else
            $scope.selectedStat = false;
            $scope.firstStat = false;
            $scope.secondStat = true;

    $scope.getActiveScan = (count) ->
        if count < 200
            $timeout(()->
                RestModel.getPhotoAll($scope.currentUser.id,$scope.params,200).then(
                    (data)->
                        $scope.offset = 0;
                        if angular.isDefined(data.response && data.response.items)
                            # список фоток
                            $scope.userPhotos.push(data.response.items);
                            $scope.userPhotos = $scope.getArrayPhoto($scope.userPhotos);
                            $scope.getLikes($scope.userPhotos);
                    (error)->
                        console.log(error);
                )
            ,300)
        else
            $timeout(()->
                RestModel.getPhotoAll($scope.currentUser.id,$scope.params,200,$scope.offset).then(
                    (data)->
                        if angular.isDefined(data.response && data.response.items)
                            $scope.offset = $scope.offset + 200;
                            count = count - 200;
                            # список фоток
                            $scope.userPhotos.push(data.response.items);
                            $scope.getActiveScan(count);
                    (error)->
                        console.log(error);
                )
            ,335)

    $scope.getArrayPhoto = (array) ->
        temp = [];
        angular.forEach(array,(items)->
            angular.forEach(items,(item)->
                temp.push(item);
            )
        )

        return temp;


    $scope.getLikes = (photos) ->
        # временное хранилище с которым работаем если фоток больше 25
        tempPhotos = '';

        # смотрим сколько фоток
        # меньше 25 - все круто, отправляем запрос
        # больше 25 - вырезаем 25 фоток и отправляем запрос, затем работаем работаем с остатком - рекурсия

        if photos.length < 25
            $timeout(()->
                RestModel.getLikesExecute($scope.currentUser.id, photos, $scope.params, "photo").then(
                    (likes)->
                        $scope.userLikes.push(likes.response);
                        $scope.isActiveFriends($scope.userLikes);
                    (error)->
                        console.log(error);
                )
            ,300)

        else
            tempPhotos = photos.splice(0, 24);
            $timeout(()->
                RestModel.getLikesExecute($scope.currentUser.id, tempPhotos, $scope.params, "photo").then(
                    (likes)->
                        $scope.userLikes.push(likes.response);
                        $scope.getLikes(photos);
                    (error)->
                        console.log(error);
                )
            ,300)


    $scope.isActiveFriends = (likesArray) ->
        tempLikesArray = [];
        angular.forEach(likesArray, (likes)->
            angular.forEach(likes, (like, key)->
                angular.forEach(like.users, (user)->
                    tempLikesArray.push(user)
                )
            )
        )


        angular.forEach(tempLikesArray, (item)->
            if $scope.arrayIdFriends[item] then $scope.arrayIdFriends[item].count = $scope.arrayIdFriends[item].count + 1;
        )

        $scope.arrayIdFriends;

        angular.forEach($scope.arrayIdFriends, (user)->
            $scope.resultStatSecond.push(user);
        );

        $scope.resultStatSecond = $scope.resultStatSecond.sort($scope.sortableLikes);
        $scope.resultStatSecond = Loader.renderBand($scope.resultStatSecond);

        $scope.selectedStat = false;
        $scope.loading = false;
        $scope.firstStat = false;
        $scope.secondStat = true;


    $scope.sortableLikes = (a,b) ->
        return b.count - a.count;


    $scope.more = (user) ->
        $state.transitionTo('user', {userId: user.id || user.uid});



