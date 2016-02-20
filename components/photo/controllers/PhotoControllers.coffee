#PhotoController#

'use strict';

PhotoModule.controller 'PhotoController', ($scope, $stateParams, $timeout, $location, RestModel, Notification, LocalStorage, params, user) ->

    $scope.window = window;
    $scope.params = params;
    $scope.stateParams = $stateParams;
    $scope.process = false;
    $scope.openOtherSearch = false;

    $scope.user = user.response[0];


    $scope.userId = $scope.user.id
    $scope.userSearchForId = $scope.stateParams.selectedId;

    $scope.back = () ->
        $location.path('/user/' + $scope.userId);

    $scope.wall = () ->
        $location.path('/user/' + $scope.userId + '/selected/' + $scope.userSearchForId + '/wall');

    # увеличение фото
    $scope.increasePhoto = (photo) ->
        $scope.process = true;
        $scope.openBigBlade = true;
        console.log(photo);
        $scope.image = photo.instance.photo_604;

    # закрыть шаблон с увеличенной фотографией
    $scope.closeBlade = () ->
        $scope.process = false;
        $scope.openBigBlade = false;

    # вернуться к форме поиска
    $scope.returnFormSearch = () ->
        $scope.likePhotos = null;
        $scope.countPhoto = null;
        $scope.typePhoto = null;
        $scope.openOtherSearch = false;

    if angular.isDefined($scope.userSearchForId)
        RestModel.moreInfo($scope.userSearchForId, $scope.params).then(
            (data)->
                $scope.userSearchFor = data.response[0];
            (error) ->
                console.log(error);
        );


    # поменять местами владельца стены и гостя
    $scope.changeUser = (user, userSearchFor) ->
        $scope.user = userSearchFor;
        $scope.userSearchFor = user;

        $scope.userId = userSearchFor.id;
        $scope.userSearchForId = user.id;

        $scope.right = !$scope.right;



    $scope.likesPhoto = (countPhoto, typePhoto) ->
        if !angular.isDefined(countPhoto)
            Notification.show("Выберите количество!");
            return true;
        if !angular.isDefined(typePhoto)
            Notification.show('Выберите тип фото');
            return true;

        $scope.openOtherSearch = true;
        $scope.process = true;
        $scope.photos = [];
        # id кого ищем
#        $scope.userSearchForId = userSearchForId;

        # количество записей
        $scope.countPhoto = countPhoto;

        # тип фото
        $scope.typePhoto = typePhoto;


        RestModel.getPhoto( $scope.userId, $scope.params, $scope.countPhoto, $scope.typePhoto).then(
            (data)->
                console.log(data);
                $scope.photos = if data.response.items.length != 0 then data.response.items else null;

                if $scope.photos isnt null
                    $scope.getLikesFromPhotos();
                else
                    $scope.likePhotos = [];
                    $scope.process = false;
            (error) ->
                console.log(error);
        )

    $scope.getLikesFromPhotos = () ->
        $scope.likePhotos = [];
        $scope.countLikes = [];
        $scope.photosLength = $scope.photos.length;
        type = "photo";

        # нагрузка - максимум 5 запросов в секунду..
        if $scope.photosLength <= 5
            $scope.photos.forEach((photo)->
                RestModel.getLikes($scope.userId, $scope.params, photo.id, type).then(
                    (data) ->
                        listId = if data.response.items then data.response.items else null;
                        if listId isnt null
                            listId.forEach((id)->
                                if id == parseFloat($scope.userSearchForId)
                                    #массив фото, которые понравились пользователю userSearchFor
                                    $scope.likePhotos.push({instance: photo, countLikes: listId.length});
                            )
                            if $scope.photos[$scope.photosLength - 1] == photo then $scope.process = false;
                    (error) ->
                        console.log(error);
                )
            )

        if $scope.photosLength > 5
            index = 0;
            $scope.getLikesRecursion($scope.photos[index], index);


    # используем рекурсию
    # так как приходится вешать $timeout после каждого 4 запроса
    $scope.getLikesRecursion = (photo, index) ->
        $scope.index = index;
        # каждый 4 запрос - это в этой ветке
        if $scope.index % 4 == 0 && $scope.index != $scope.photosLength && $scope.index != 0
            console.log($scope.index);
            $timeout(()->
                $scope.getLikes(photo);
            ,2000)

        # остальные запросы
        if $scope.index % 4 != 0 && $scope.index != $scope.photosLength || $scope.index == 0
            $scope.getLikes(photo);

        # выходим из рекурсии
        if index == $scope.photosLength
            console.log($scope.likePhotos);
            $scope.process = false;
            return true


    $scope.getLikes = (photo) ->
        console.log(photo);
        type = "photo";
        RestModel.getLikes($scope.userId, $scope.params, photo.id, type).then(
            (data) ->
                $scope.index = $scope.index + 1;
                listId = if data.response.items then data.response.items else null;
                if listId isnt null
                    listId.forEach((id)->
                        if id == parseFloat($scope.userSearchForId)
                            $scope.likePhotos.push({instance: photo, countLikes: listId.length});
                    )
                $scope.getLikesRecursion($scope.photos[$scope.index], $scope.index);
            (error) ->
                console.log(error);
                if error.code == 6
                    $timeout(()->
                        $scope.getLikeRecursion(photo, $scope.index);
                    ,3000)
        )

    $scope.page = 1;
    $scope.pageSize = 1;
    $scope.i = 0;

    $scope.isActive = (index) ->
        $scope.i == index + 1;

    # для мобильных устройств
    $scope.showPrev =  (photo) ->
        $('.next').click();
        true;

    $scope.showNext = (photo) ->
        $('.next').click();
        true;

#    $scope.showPhoto = (index) ->
#        $scope.i = index;
#        $scope.page = index + 1;


# http://vk.com/dev/photos.getComments - подумать с комментариями

