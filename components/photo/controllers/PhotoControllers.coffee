#PhotoController#

'use strict';

PhotoModule.controller 'PhotoController', ($scope, $stateParams, $timeout, $location, RestModel, Notification, LocalStorage, params, user,userSearchFor) ->

    $scope.window = window;
    $scope.params = params;
    $scope.stateParams = $stateParams;
    $scope.openOtherSearch = false;
    $scope.loading = false;

    $scope.user = user.response[0];


    $scope.userId = $scope.user.id
    $scope.userSearchForId = $scope.stateParams.selectedId;
    $scope.userSearchFor = userSearchFor;


    $scope.back = () ->
        $location.path('/user/' + $scope.userId);

    $scope.wall = () ->
        $location.path('/user/' + $scope.userId + '/selected/' + $scope.userSearchForId + '/wall');

    # увеличение фото
    $scope.increasePhoto = (photo) ->
        $scope.process = true;
        $scope.openBigBlade = true;
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


    # поменять местами владельца стены и гостя
    $scope.changeUser = (user, userSearchFor) ->
        $scope.user = userSearchFor;
        $scope.userSearchFor = user;

        $scope.userId = userSearchFor.id;
        $scope.userSearchForId = user.id;

        $scope.right = !$scope.right;



    $scope.likesPhoto = (countPhoto, typePhoto) ->
        if !angular.isDefined(countPhoto)
            Notification.success("Выберите количество!");
            return true;
        if !angular.isDefined(typePhoto)
            Notification.success('Выберите тип фото');
            return true;

        $scope.openOtherSearch = true;
        $scope.photos = [];
        $scope.loading = true;
        # id кого ищем
#        $scope.userSearchForId = userSearchForId;

        # количество записей
        $scope.countPhoto = countPhoto;

        # тип фото
        $scope.typePhoto = typePhoto;


        RestModel.getPhoto( $scope.userId, $scope.params, $scope.countPhoto, $scope.typePhoto).then(
            (data)->
                $scope.photos = if data.response.items.length != 0 then data.response.items else null;

                if $scope.photos isnt null
                    $scope.getLikesFromPhotos();
                else
                    $scope.loading = false;
                    $scope.likePhotos = [];
            (error) ->
                Notification.error(error);
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
                            if $scope.photos[$scope.photosLength - 1] == photo then $scope.loading = false;
                    (error) ->
                        Notification.error(error);
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
            $timeout(()->
                $scope.getLikes(photo);
            ,2000)

        # остальные запросы
        if $scope.index % 4 != 0 && $scope.index != $scope.photosLength || $scope.index == 0
            $scope.getLikes(photo);

        # выходим из рекурсии
        if index == $scope.photosLength
            $scope.loading = false;
            return true


    $scope.getLikes = (photo) ->
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


