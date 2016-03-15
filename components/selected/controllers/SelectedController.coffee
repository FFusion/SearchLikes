#SelectedController#

'use strict'

SelectedModule.controller 'SelectedController', ($scope, $stateParams, $location, $timeout, RestModel, params) ->

    $scope.params = params;
    $scope.window = window;
    $scope.stateParams = $stateParams;
    $scope.loading = true;

    $scope.userId = $scope.stateParams.userId;
    #тип стена или фото
    $scope.type = $scope.stateParams.type;

    $scope.selected = null;

    $scope.page = 1;
    $scope.pageSize = 7;


    $scope.searchPhotoAmongAllUsers = (userFriends) ->
        # берем одного чувака
        user = userFriends.splice(0,1);

        # получаем фотки профиля этого чувака
        $timeout(()->
            RestModel.getPhoto(user[0].id, $scope.params,1000,"profile").then((data)->
                photos = data.response.items;
                if photos.length == 0 then $scope.searchPhotoAmongAllUsers(userFriends);
                $scope.getLikesFromsPhotos(userFriends,photos);
            )
        ,500)

    $scope.getLikesFromsPhotos = (userFriends,photos, arrayLikes = null) ->
        tempPhotos = '';
        $scope.loading = true;
        # получаем лайки на фотках
        if photos.length < 25
            $scope.arrayLikes = arrayLikes || [];
            RestModel.getLikesExecute($scope.userId, photos, $scope.params).then(
                (likes)->
                    $scope.arrayLikes.push(likes);
                    $scope.isSearchLikes(userFriends, $scope.arrayLikes);
                (error)->console.log(error);
            )
        else
            $scope.arrayLikes = arrayLikes || [];
            tempPhotos = photos.splice(0, 25);
            console.log('photos',photos);
            RestModel.getLikesExecute($scope.userId, photos, $scope.params).then((likes)->
                $scope.arrayLikes.push(likes);
                $scope.getLikesFromsPhotos(userFriends, photos,$scope.arrayLikes);
            )

    $scope.back = () ->
        $scope.window.history.back();

    RestModel.getUserById($scope.userId, $scope.params).then(
        (data)->
            $scope.currentUser = data.response[0];
        (error) ->
            console.log(error);
    );

    RestModel.getFriends(params, $scope.userId).then(
        (data)->
            $scope.loading = false;
            $scope.countFriends = data.response.count;
            $scope.userFriends = RestModel.isWorkingFriendsObject(data);
        (error) ->
            console.log(error);

    )

    $scope.isSearchLikes = (userFriends,likes) ->
        $scope.loading = false;
        console.log(likes);

        $scope.searchPhotoAmongAllUsers(userFriends);

    $scope.isSelected = (selected) ->
        if $scope.selected isnt null && selected == $scope.selected
            $scope.selected = null
        else
            $scope.selected = selected;

    $scope.selectUserNext = () ->
        $location.path('user/' + $scope.userId + '/selected/' + $scope.selected.id + '/' + $scope.type);
