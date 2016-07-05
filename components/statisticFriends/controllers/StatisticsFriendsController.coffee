#StatisticsFriendsController#

'use strict'

StatisticsFriendsModule.controller 'StatisticsFriendsController', ($scope, Static, $stateParams, $state, $location, $timeout, RestModel, Loader, params, currentUser, friends) ->

    $scope.params = params;
    Static.params = params;
    Static.resultFriends = [];
    $scope.currentUser = currentUser.response[0];
    $scope.friends = friends.response.items;
    $scope.offset = 0;
    $scope.objectDate = {};
    $scope.objectDate.date = "first";

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
            $scope.loading = true;
            Static.getListCountFriends(statisticFriends).then((data)->
                $scope.resultFriends = data;
                $scope.loading = false;
                $scope.selectedStat = false;
                $scope.firstStat = true;
                $scope.secondStat = false;
                $scope.thirdStat = false;
                $scope.fourStat = false;
            );

        else
            $scope.selectedStat = false;
            $scope.firstStat = true;
            $scope.secondStat = false;
            $scope.thirdStat = false;
            $scope.fourStat = false;


    # статистика по активности на фото
    $scope.getStatActiveUser = () ->
        $scope.userPhotos = [];
        $scope.userLikes = [];
        console.log($scope.resultStatSecond);
#        if !$scope.resultStatSecond
        $scope.resultStatSecond = [];
        $scope.arrayIdFriendsPhoto = {};
        statisticFriends = RestModel.friendsOnlineOrDelete(null, $scope.friends);
        angular.forEach(statisticFriends, (user)->
            $scope.arrayIdFriendsPhoto[user.id] = user;
            $scope.arrayIdFriendsPhoto[user.id].count = 0;
        )
        $scope.getActiveScan($scope.currentUser.counters.photos);
        $scope.loading = true;
#        else
#            $scope.selectedStat = false;
#            $scope.firstStat = false;
#            $scope.secondStat = true;
#            $scope.thirdStat = false;

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
                            $scope.getLikes($scope.userPhotos, "photo");
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


    $scope.getLikes = (photos, type = null) ->
        if type isnt null then $scope.type = type;
        # временное хранилище с которым работаем если фоток больше 25
        tempPhotos = '';

        # смотрим сколько фоток
        # меньше 25 - все круто, отправляем запрос
        # больше 25 - вырезаем 25 фоток и отправляем запрос, затем работаем работаем с остатком - рекурсия

        if photos.length < 25
            if photos.length != 0
                $timeout(()->
                    RestModel.getLikesExecute($scope.currentUser.id, photos, $scope.params, $scope.type).then(
                        (likes)->
                            $scope.userLikes.push(likes.response);
                            $scope.isActiveFriends($scope.userLikes, $scope.type);
                        (error)->
                            console.log(error);
                    )
                ,300)
            else
                $scope.selectedStat = false;
                $scope.loading = false;
                $scope.firstStat = false;
                $scope.secondStat = true;
                $scope.thirdStat = false;

        else
            tempPhotos = photos.splice(0, 24);
            $timeout(()->
                RestModel.getLikesExecute($scope.currentUser.id, tempPhotos, $scope.params, $scope.type).then(
                    (likes)->
                        $scope.userLikes.push(likes.response);
                        $scope.getLikes(photos);
                    (error)->
                        console.log(error);
                )
            ,300)


    $scope.isActiveFriends = (likesArray, type) ->
        tempLikesArray = [];
        angular.forEach(likesArray, (likes)->
            angular.forEach(likes, (like, key)->
                angular.forEach(like.users, (user)->
                    tempLikesArray.push(user)
                )
            )
        )


        if type == 'post'
            angular.forEach(tempLikesArray, (item)->
                if $scope.arrayIdFriendsWall[item] then $scope.arrayIdFriendsWall[item].count = $scope.arrayIdFriendsWall[item].count + 1;
            )

            angular.forEach($scope.arrayIdFriendsWall, (user)->
                $scope.resultStatThird.push(user);
            );
            $scope.resultStatThird = $scope.resultStatThird.sort($scope.sortableLikes);
            $scope.resultStatThird = Loader.renderBand($scope.resultStatThird);

            $scope.selectedStat = false;
            $scope.loading = false;
            $scope.firstStat = false;
            $scope.secondStat = false;
            $scope.thirdStat = true;
            $scope.fourStat = false;
        else
            angular.forEach(tempLikesArray, (item)->
                if $scope.arrayIdFriendsPhoto[item] then $scope.arrayIdFriendsPhoto[item].count = $scope.arrayIdFriendsPhoto[item].count + 1;
            )

            angular.forEach($scope.arrayIdFriendsPhoto, (user)->
                $scope.resultStatSecond.push(user);
            );
            $scope.resultStatSecond = $scope.resultStatSecond.sort($scope.sortableLikes);
            $scope.resultStatSecond = Loader.renderBand($scope.resultStatSecond);

            $scope.selectedStat = false;
            $scope.loading = false;
            $scope.firstStat = false;
            $scope.secondStat = true;
            $scope.thirdStat = false;
            $scope.fourStat = false;






    $scope.sortableLikes = (a,b) ->
        return b.count - a.count;


    $scope.more = (user) ->
        $state.transitionTo('user', {userId: user.id || user.uid});


    # статистика по активности на стене
    $scope.getStatActiveUserWall = () ->
        $scope.userWall = [];
        $scope.userLikes = [];
#        if !$scope.resultStatThird
        $scope.resultStatThird = [];
        $scope.arrayIdFriendsWall = {};
        statisticFriends = RestModel.friendsOnlineOrDelete(null, $scope.friends);
        angular.forEach(statisticFriends, (user)->
            $scope.arrayIdFriendsWall[user.id] = user;
            $scope.arrayIdFriendsWall[user.id].count = 0;
        )
        $scope.getScanUserWall();

#            $scope.getActiveScan($scope.currentUser);
        $scope.loading = true;
#        else
#            $scope.selectedStat = false;
#            $scope.firstStat = false;
#            $scope.secondStat = false;
#            $scope.thirdStat = true;



    $scope.getScanUserWall = (count = null) ->
        if count is null then $scope.offset = 0;

        if count < 100 || count is null
            $timeout(()->
                RestModel.getAllWallPost($scope.currentUser.id,$scope.params, count || 100,$scope.offset).then(
                    (data)->
                        if count is null then count = data.response.count; $scope.wallPosts = data.response.count;
                        $scope.userWall.push(data.response.items);

                        if count < 100
                            $scope.isLikesFromWall($scope.userWall);
                        else
                            count = count - 100;
                            $scope.offset = $scope.offset + 100;
                            $scope.getScanUserWall(count);
                    (error)-> console.log(error);
                );
            ,335)

        else
            $timeout(()->
                RestModel.getAllWallPost($scope.currentUser.id,$scope.params, 100,$scope.offset).then(
                    (data)->
                        $scope.userWall.push(data.response.items);
                        count = count - 100;
                        $scope.offset = $scope.offset + 100;
                        $scope.getScanUserWall(count);
                    (error)->
                        console.log(error);
                )
            ,335)

    $scope.isLikesFromWall = (walls) ->
        arrayPost = [];
        angular.forEach(walls, (items)->
            angular.forEach(items,(item)->
                if item.likes.count != 0 then arrayPost.push(item);
            )
        )

        $scope.getLikes(arrayPost, 'post');




    $scope.showAvaType = () ->

        $scope.selectedStat = false;
        $scope.firstStat = false;
        $scope.secondStat = false;
        $scope.thirdStat = false;
        $scope.fourStat = true;
        $scope.resultStatFour = [];


    $scope.getUpdatePhoto = () ->
        currentDate = new Date();
        if $scope.objectDate.date == 'first'
            currentDate.setDate(currentDate.getDate() - 1);
            times = Math.round(currentDate.getTime()/1000.0);
            console.log(times);
        else
            currentDate.setDate(currentDate.getDate() - 7);
            times = Math.round(currentDate.getTime()/1000.0);

            
        $scope.resultStatFour = [];
        statisticFriends = RestModel.friendsOnlineOrDelete(null, $scope.friends);



        Static.getPhotoProfileFriends(statisticFriends, times).then((data)->
            $scope.resultStatFour = data;
            $scope.loading = false;
            $scope.selectedStat = false;
            $scope.firstStat = false;
            $scope.secondStat = false;
            $scope.thirdStat = false;
            $scope.fourStat = true;

            (error)-> console.log(error);
        )

        $scope.loading = true;


# todo: переписать через сервис



