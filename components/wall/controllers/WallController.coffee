#WallController#

'use strict'

WallModule.controller 'WallController', ($scope, $stateParams, $location, RestModel, params, $timeout, $window, user) ->

    $scope.stateParams = $stateParams;
    $scope.window = window;

    $scope.process = false;
    $scope.openOtherSearch = false;
    $scope.isOpen = false;
    $scope.params = params;

    $scope.user = user.response[0];

    $scope.userId = $scope.stateParams.userId;
    $scope.userSearchForId = $scope.stateParams.selectedId;

    $scope.back = () ->
        $location.path('user/' + $scope.userId);

    $scope.photo = () ->
        $location.path('user/' + $scope.userId + '/selected/' + $scope.userSearchForId + '/photo');

    # вернуться к форме поиска
    $scope.returnFormSearch = () ->
        $scope.likePosts = null;
        $scope.countPost = null;
        $scope.openOtherSearch = false;


    # поменять местами владельца стены и гостя
    $scope.changeUser = (user, userSearchFor) ->
        $scope.user = userSearchFor;
        $scope.userSearchFor = user;

        $scope.userId = userSearchFor.id;
        $scope.userSearchForId = user.id;

        $scope.right = !$scope.right;

    # увеличение фото из записи стены
    $scope.increasePhoto = (photo) ->
       $scope.process = true;
       $scope.openBigBlade = true;
       $scope.image = photo.photo_604;

    # закрыть шаблон с увеличенной фотографией
    $scope.closeBlade = () ->
        $scope.process = false;
        $scope.openBigBlade = false;


    if angular.isDefined($scope.userSearchForId)
        RestModel.moreInfo($scope.userSearchForId, $scope.params).then(
            (data)->
                $scope.userSearchFor = data.response[0];
            (error) ->
                console.log(error);
        );

    $scope.likesWall = (countPost) ->
        $scope.openOtherSearch = true;
        $scope.process = true;
        # id кого ищем
#        $scope.userSearchForId = userSearchForId;

        # количество записей
        $scope.countPost = countPost;

        RestModel.getWallPost($scope.userId, $scope.params, $scope.countPost).then(
            (data) ->
                # массив записей со стены
                $scope.posts = if data.response.items.length != 0 then data.response.items else null

                if $scope.posts isnt null
                    $scope.getLikesFromPosts();
                else
                    $scope.likePosts = [];
                    $scope.process = false;
            (error) ->
                console.log(error);
        )

    # получаем лайки
    $scope.getLikesFromPosts = () ->
        $scope.likePosts = [];
        $scope.postsLength = $scope.posts.length;
        type = "post";

        # нагрузка - максимум 5 запросов в секунду..
        if $scope.postsLength <= 5
            $scope.posts.forEach((post)->
                RestModel.getLikes($scope.userId, $scope.params, post.id, type).then(
                    (data) ->
                        listId = if data.response.items then data.response.items else null;
                        if listId isnt null
                            listId.forEach((id)->
                                if id == parseFloat($scope.userSearchForId)
                                    #массив записей, которые понравились пользователю userSearchFor
                                    $scope.likePosts.push(post);
                                )
                            if $scope.posts[$scope.postsLength - 1] == post then $scope.process = false;
                    (error) ->
                        console.log(error);
                )
            )                        

        if $scope.postsLength > 5
            index = 0;
            $scope.getLikesRecursion($scope.posts[index], index);


    # используем рекурсию
    # так как приходится вешать $timeout после каждого 4 запроса
    $scope.getLikesRecursion = (post, index) ->
        $scope.index = index;
        # каждый 4 запрос - это в этой ветке
        if $scope.index % 4 == 0 && $scope.index != $scope.postsLength && $scope.index != 0
            $timeout(()->
                $scope.getLikes(post);
            ,2000)

        # остальные запросы
        if $scope.index % 4 != 0 && $scope.index != $scope.postsLength || $scope.index == 0
           $scope.getLikes(post);

        # выходим из рекурсии
        if index == $scope.postsLength
            console.log($scope.likePosts);
            $scope.process = false;
            return true


    $scope.getLikes = (post) ->
        console.log(post);
        type = "post";
        RestModel.getLikes($scope.userId, $scope.params, post.id, type).then(
            (data) ->
                $scope.index = $scope.index + 1;
                listId = if data.response.items then data.response.items else null;
                if listId isnt null
                    listId.forEach((id)->
                        if id == parseFloat($scope.userSearchForId)
                            $scope.likePosts.push(post);
                    )
                $scope.getLikesRecursion($scope.posts[$scope.index], $scope.index);
            (error) ->
                console.log(error);
                if error.code == 6
                    $timeout(()->
                        $scope.getLikeRecursion(post, $scope.index);
                    ,2000)
        )

        $scope.openMusic = (attachment) ->
            attachment.isOpen = !attachment.isOpen;