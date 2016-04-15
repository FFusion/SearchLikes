#CommentsPhotoController#

'use strict';
CommentsPhotoModule.controller 'CommentsPhotoController', ($scope, params, $stateParams, $timeout, RestModel, Loader, currentUser, friends) ->
    $scope.params = params;
    $scope.window = window;
    $scope.loading = false;
    $scope.comments = [];
    $scope.result = false;
    $scope.count = 0;

    $scope.stopped = false;
    $scope.lookedItems = false;
    $scope.onlyCurrent = true;

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
        $scope.window.history.back();

    $scope.allFriends = angular.copy($scope.userFriends);

    $scope.getComments = (userFriends) ->
        Loader.startLoad();

        $scope.isResultComments = [];

        $scope.result = false;
        $scope.stopped = false;

        $scope.procent = 0;
        $scope.count = 0;
        $scope.offset = 0;

        # смотрим на выбранную категорию и фильтруем пользователей
        scaningUsers = RestModel.filteredUsers(userFriends, $scope.type.typeUsers);

        $scope.allCountUsers = scaningUsers.length;
        $scope.searchCommentAmongUsers(scaningUsers);

    $scope.searchCommentAmongUsers = (users) ->
        # берем одного чувака
        checkedUser = users.splice(0,1);

        $scope.comments = [];

        $scope.procent = 100 - Math.floor(users.length * 100 / $scope.allCountUsers);
        Loader.process($scope.procent);

        if checkedUser.length > 0
            $timeout(()->
            # получаем число комментов на фотках
                RestModel.getCommentsCount(checkedUser[0].id, $scope.params).then(
                    (data)->
                        if !data.error
                            count = data.response.count;
                        # комменты есть, идем дальше
                        # иначе берем следующего
                            if count > 0
                                $scope.getCommentsOfCheckedUser(checkedUser, count, users);
                            else
                                $scope.searchCommentAmongUsers(users);
                        else
                            $scope.searchCommentAmongUsers(users);
                    (error)->
                        console.log(error);
                        $scope.searchCommentAmongUsers(users);
                    )
            ,335)

        else
            console.log('no');

    $scope.getCommentsOfCheckedUser = (checkedUser, count, users) ->
        # комментов меньше 100 - получаем запросом
        # больше 100 - через offset
        if count < 100
            $timeout(()->
                RestModel.getCommentsCount(checkedUser[0].id, $scope.params, 100).then(
                    (data)->
                        $scope.comments.push(data.response.items);
                        $scope.offset = 0;
                        $scope.workingWithComment(checkedUser, $scope.comments, users);
                    (error)->
                        console.log(error);
                        $scope.searchCommentAmongUsers(users);
                )
            ,335)
        else
            $scope.arrayComments = [];
            $timeout(()->
                # получаем число комментов на фотках
                RestModel.getCommentsCount(checkedUser[0].id, $scope.params, 100, $scope.offset).then(
                    (data)->
                        $scope.comments.push(data.response.items);
                        $scope.offset = $scope.offset + 100;
                        count = count - 100;
                        $scope.getCommentsOfCheckedUser(checkedUser, count, users);
                    (error)->
                        console.log(error);
                        $scope.searchCommentAmongUsers(users);
                )
            ,335);



    $scope.workingWithComment = (checkedUser, comments, users) ->
        $scope.isResultComments.push({user:checkedUser, photosId:[], allComments:[], photos:{}});
#        if checkedUser.last_name == "Батин" then console.log(comments);

        angular.forEach(comments, (list)->
            angular.forEach(list, (comment) ->
                if comment.from_id == parseInt($scope.userId)
                    $scope.isResultComments[$scope.count].photosId.push(comment.pid);
                    comment.date = moment.unix(comment.date).format('DD.MM.YYYY HH:mm');
                    $scope.isResultComments[$scope.count].allComments.push(comment);
            )

        )

        if  $scope.isResultComments[$scope.count].photosId.length > 0
            $scope.getPhotoWithComment($scope.isResultComments[$scope.count]).then((data)->
                $scope.isResultComments[$scope.count] = data;
                $scope.count = $scope.count + 1;
            )
        else
            $scope.count = $scope.count + 1;

        if $scope.isResultComments.length > 0 then $scope.result = true;
        if users.length != 0 && !$scope.stopped then $scope.searchCommentAmongUsers(users) else Loader.stopLoad();




    $scope.getPhotoWithComment = (object) ->
        oblectPhotosId = {};
        oblectComments = {};
        # фильтруем фото
        angular.forEach(object.photosId, (id, index) ->
            oblectPhotosId[id] = [];
        )

        # фильтруем комменты
        angular.forEach(object.allComments, (comment, index) ->
            oblectComments[comment.id] = comment;
        )


        photosId = '';
        angular.forEach(oblectPhotosId, (item, key, index) ->
            photosId = photosId + object.user[0].id + '_' + key + ','
        )

        # строка запроса для получения фото
        photosId = photosId.slice(0,-1);

        $timeout(()->
            RestModel.getPhotosById(photosId).then(
                (data)->
                    object.photos = data.response;
                    angular.forEach(object.photos, (photo)->
                        photo.comments = [];
                        angular.forEach(oblectComments, (comment)->
                            if photo.id == parseInt(comment.pid) then photo.comments.push(comment);
                        )
                    )
                    console.log(object);
                    return object;
                (error)->
                    console.log(error);
            )
        ,335);
    # остановить сканирование
    $scope.stopScan = () ->
        $scope.stopped = true;

    $scope.lookComments = (photosComments, comments) ->
        if angular.isDefined(photosComments)
            $scope.lookedComments = photosComments;
            $scope.lookedOnlyComments = false;
        else
            $scope.lookedComments = false;
            $scope.lookedOnlyComments = comments
        $scope.lookedItems = true;

        $scope.offcet = window.pageYOffset;
        $('body').scrollTop(0);

        return true;


    $scope.lookAllCommentForPhoto = (photo) ->
        $scope.loading = true;
        RestModel.getCommentsByPhoto(photo, $scope.params).then(
            (comments)->
                $scope.onlyCurrent = false;
                angular.forEach(comments.response.profiles, (profile)->
                    angular.forEach(comments.response.items, (comment)->
                        if comment.from_id == parseInt(profile.id)
                            comment.user = profile;
                            comment.date = moment.unix(comment.date).format('DD.MM.YYYY HH:mm');
                    )
                )
                $scope.loading = false;

                $scope.all = comments.response.items;

            (error)->
                console.log(error);

        )
