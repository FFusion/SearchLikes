#ProcessingPhotoController#

'use strict'

ProcessingPhotoModule.controller 'ProcessingPhotoController', ($scope, $stateParams, $location, $timeout, RestModel, Loader, params, currentUser, friends) ->

    $scope.params = params;
    $scope.window = window;
    $scope.loading = false;
    $scope.isLikes = [];
    $scope.result = false;
    $scope.count = 0;

    $scope.stopped = false;
    $scope.lookedItems = false;
    $scope.procent = 0;

    $scope.type = {};
    $scope.type.typeUsers = "all"



    $scope.userId = $stateParams.userId;
    $scope.currentUser = currentUser.response[0];

    $scope.countFriends = friends.response.count;
    $scope.userFriends = RestModel.isWorkingFriendsObject(friends);

    $scope.back = () ->
        $scope.stopped = true;
        if Loader.ID isnt null
            Loader.stopLoad();
        $scope.window.history.back()

    $scope.allFriends = angular.copy($scope.userFriends);

    $scope.scaned = (userFriends) ->
        Loader.startLoad();
#        scaningUsers = [];
        $scope.isLikes = [];

        $scope.result = false;
        $scope.stopped = false;

        $scope.procent = 0;
        $scope.count = 0;

        # смотрим на выбранную категорию и фильтруем пользователей
        scaningUsers = RestModel.filteredUsers(userFriends, $scope.type.typeUsers);

        $scope.allCountUsers = scaningUsers.length;
        $scope.searchPhotoAmongUsers(scaningUsers);

    # функция сканирования
    $scope.searchPhotoAmongUsers = (userFriends) ->

        # берем одного чувака
        checkedUser = userFriends.splice(0,1);

        # массив фоток чувака
        $scope.userPhotos = [];
        # массив лайков на фотках чувака
        $scope.userLikes = [];


        $scope.procent = 100 - Math.floor(userFriends.length * 100 / $scope.allCountUsers);
        Loader.process($scope.procent);

        if checkedUser != undefined
            # получаем фотки профиля этого чувака
            $timeout(()->
                RestModel.getPhoto(checkedUser[0].id, $scope.params, 1000, "profile").then(
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
                        console.log(error);
                        $scope.searchPhotoAmongUsers(userFriends);
                )
            ,300)

        else
            console.log('no');


    $scope.getLikesFromsPhotos = (checkedUser,userFriends,photos) ->
        # временное хранилище с которым работаем если фоток больше 25
        tempPhotos = '';

        # смотрим сколько фоток
        # меньше 25 - все круто, отправляем запрос
        # больше 25 - вырезаем 25 фоток и отправляем запрос, затем работаем работаем с остатком - рекурсия

        if photos.length < 25
            $timeout(()->
                RestModel.getLikesExecute($scope.userId, photos, $scope.params, "photo").then(
                    (likes)->
                        $scope.userPhotos.push(photos);
                        $scope.userLikes.push(likes.response);
                        $scope.isSearchLikes(checkedUser,userFriends, $scope.userPhotos, $scope.userLikes);
                    (error)->
                        console.log(error);
                )
            ,300)

        else
            tempPhotos = photos.splice(0, 24);
            $timeout(()->
                RestModel.getLikesExecute($scope.userId, tempPhotos, $scope.params, "photo").then(
                    (likes)->
                        $scope.userPhotos.push(tempPhotos);
                        $scope.userLikes.push(likes.response);
                        $scope.getLikesFromsPhotos(checkedUser, userFriends, photos);
                    (error)->
                        console.log(error);
                )
            ,300)


    # ищем среди лайков на фотках текущего пользователя
    $scope.isSearchLikes = (checkedUser, userFriends, userPhotos, userLikes) ->

        # итоговый массив - обрабатываемый пользователь,фотографии с лайками кол-во фото
        $scope.isLikes.push({user:checkedUser, photos:[], photosCount:''});

        angular.forEach(userLikes, (likes)->
            angular.forEach(likes, (like, key)->
                photoId = parseInt(key.replace(/\D+/g,""));
                angular.forEach(like.users, (user)->
                    if user == parseInt($scope.userId)
                        if userPhotos
                            $scope.addPhotoWithLike(checkedUser, photoId, userPhotos);
                )
            )
        )

        if $scope.isLikes.length > 0 then $scope.result = true;
        $scope.count = $scope.count + 1;

        if userFriends.length != 0 && !$scope.stopped then $scope.searchPhotoAmongUsers(userFriends) else Loader.stopLoad();


    # выбираем фотки с нужным нам лайком
    $scope.addPhotoWithLike = (checkedUser, photoId, userPhotos) ->
        count = 0;
        angular.forEach(userPhotos, (photos)->
            count = count + photos.length;
            angular.forEach(photos, (photo)->
                if photo.id == photoId
                    $scope.isLikes[$scope.count].photos.push(photo);
            )
        )

        $scope.isLikes[$scope.count].photosCount = count;

    # остановить сканирование
    $scope.stopScan = () ->
        $scope.stopped = true;

    $scope.lookPhoto = (photos) ->
        $scope.lookPhotos = photos;
        $scope.lookedItems = true;

        $scope.offcet = window.pageYOffset;
        $('body').scrollTop(0);

        return true;

