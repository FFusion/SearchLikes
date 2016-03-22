#ProcessingPhotoController#

'use strict'

SelectedModule.controller 'ProcessingPhotoController', ($scope, $stateParams, $location, $timeout, RestModel, params, currentUser, friends) ->

    $scope.params = params;
    $scope.window = window;
    $scope.loading = false;
    $scope.isLikes = [];
    $scope.result = false;
    $scope.count = 0;

    $scope.typeUsers = "all"



    $scope.userId = $stateParams.userId;
    $scope.currentUser = currentUser.response[0];

    $scope.countFriends = friends.response.count;
    $scope.userFriends = RestModel.isWorkingFriendsObject(friends);

    $scope.back = () ->
        $scope.window.history.back()

    $scope.allFriends = angular.copy($scope.userFriends);

    $scope.scaned = (userFriends) ->
        scaningUsers = [];
        $scope.isLikes = [];
        $scope.result = false;
        $scope.procent = 0;

        # смотрим на выбранную категорию и фильтруем пользователей
        angular.forEach(userFriends, (friend)->
            if $scope.typeUsers == "male" && friend.sex == 2 && !angular.isDefined(friend.deactivated)
                scaningUsers.push(friend);
            if $scope.typeUsers == "female" && friend.sex == 1 && !angular.isDefined(friend.deactivated)
                scaningUsers.push(friend);
        );

        if  $scope.typeUsers == "all"
            $scope.searchPhotoAmongUsers(userFriends)
            $scope.allCountUsers = userFriends.length;
        else
            $scope.searchPhotoAmongUsers(scaningUsers);
            $scope.allCountUsers = scaningUsers.length;

    # функция сканирования
    $scope.searchPhotoAmongUsers = (userFriends) ->
        # берем одного чувака
        checkedUser = userFriends.splice(0,1);
        $scope.procent = 100 - Math.floor(userFriends.length * 100 / $scope.allCountUsers);

        if checkedUser != undefined
            # получаем фотки профиля этого чувака
            $timeout(()->
                RestModel.getPhoto(checkedUser[0].id, $scope.params,1000,"profile").then(
                    (data)->
                        if angular.isDefined(data.response && data.response.items)
                            # список фоток
                            photos = data.response.items;
                            if photos.length == 0
                                $scope.searchPhotoAmongUsers(userFriends);
                            else
                                # получаем список лайков к этим фоткам
                                $scope.getLikesFromsPhotos(checkedUser,userFriends,photos);
                        else
                            $scope.searchPhotoAmongUsers(userFriends);
                    (error)->
                        $scope.searchPhotoAmongUsers(userFriends);
                )
            ,220)

        else
            console.log('dct');


    $scope.getLikesFromsPhotos = (checkedUser,userFriends,photos, arrayLikes = null) ->
        # временное хранилище с которым работаем если фоток больше 25
        tempPhotos = '';

        # смотрим сколько фоток
        # меньше 25 - все круто, отправляем запрос
        # больше 25 - вырезаем 25 фоток и отправляем запрос, затем работаем работаем с остатком - рекурсия

        if photos.length < 25
            $scope.arrayLikes = arrayLikes || [];
            $timeout(()->
                RestModel.getLikesExecute($scope.userId, photos, $scope.params).then(
                    (likes)->
                        $scope.arrayLikes.push({photo:photos, likes:likes});
                        $scope.isSearchLikes(checkedUser,userFriends, $scope.arrayLikes);
                    (error)->
                        console.log(error);
                )
            ,220)

        else
            $scope.arrayLikes = arrayLikes || [];
            tempPhotos = photos.splice(0, 24);
            RestModel.getLikesExecute($scope.userId, tempPhotos, $scope.params).then((likes)->
                $scope.arrayLikes.push({photo:tempPhotos, likes:likes});
                $scope.getLikesFromsPhotos(checkedUser, userFriends, photos, $scope.arrayLikes);
            )


    # ищем среди лайков на фотках текущего пользователя
    $scope.isSearchLikes = (checkedUser,userFriends,arrayLikes) ->
        # итоговый массив - обрабатываемый пользователь и фотографии с лайками
        $scope.isLikes.push({user:checkedUser, photos:[]});

        angular.forEach(arrayLikes, (data)->
            angular.forEach(data.likes.response, (item,key)->
                photoId = parseInt(key.replace(/\D+/g,""));
                angular.forEach(item.users, (user)->
                    if user == parseInt($scope.userId)
                        if data.photo
                            $scope.addPhotoWithLike(checkedUser, photoId, data.photo);
                        else
                            $scope.searchPhotoAmongUsers(userFriends);
                )
            )
        )
        if $scope.isLikes.length > 0 then $scope.result = true;

        $scope.count = $scope.count + 1;

        if userFriends.length != 0 then $scope.searchPhotoAmongUsers(userFriends);

    # выбираем фотки с нужным нам лайком
    $scope.addPhotoWithLike = (checkedUser,photoId,photos) ->
        angular.forEach(photos, (photo)->
            if photo.id == photoId
                $scope.isLikes[$scope.count].photos.push(photo);
        )

#todo: 150 друзей около 2 минут..