#ProcessingPhotoController#

'use strict'

ProcessingWallModule.controller 'ProcessingWallController', ($scope, $stateParams, $location, $timeout, RestModel, Loader, params, currentUser, friends) ->

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
        Loader.stopLoad();
        $scope.window.history.back()

    $scope.allFriends = angular.copy($scope.userFriends);

    $scope.scanedWall = (userFriends) ->
        Loader.startLoad();
        scaningUsers = [];
        $scope.isLikes = [];

        $scope.result = false;
        $scope.stopped = false;

        $scope.procent = 0;
        $scope.count = 0;

        # смотрим на выбранную категорию и фильтруем пользователей
        scaningUsers = RestModel.filteredUsers(userFriends, $scope.type.typeUsers);

        $scope.allCountUsers = scaningUsers.length;
        $scope.searchWallAmongUsers(scaningUsers);


    # функция сканирования
    $scope.searchWallAmongUsers = (userFriends) ->

        # берем одного чувака
        checkedUser = userFriends.splice(0,1);

        # массив записей чувака
        $scope.userWalls = [];
        # массив лайков на записях чувака
        $scope.userLikes = [];


        $scope.procent = 100 - Math.floor(userFriends.length * 100 / $scope.allCountUsers);
        Loader.process($scope.procent);

        if checkedUser != undefined
            # получаем фотки профиля этого чувака
            $timeout(()->
                RestModel.getWallPost(checkedUser[0].id, $scope.params, 100).then(
                    (data)->
                        if angular.isDefined(data.response && data.response.items)
                            # список записей
                            walls = data.response.items;
                            if walls.length == 0
                                $scope.searchWallAmongUsers(userFriends);
                            else
                                # получаем список лайков к этим записям
                                $scope.getLikesFromsWalls(checkedUser, userFriends, walls);
                        else
                            $scope.searchWallAmongUsers(userFriends);
                    (error)->
                        console.log(error);
                        $scope.searchWallAmongUsers(userFriends);
                )
            ,300)

        else
            console.log('no');

    $scope.getLikesFromsWalls = (checkedUser, userFriends, walls) ->
        # временное хранилище с которым работаем если записей больше 25
        tempWalls = '';

        # смотрим сколько записей
        # меньше 25 - все круто, отправляем запрос
        # больше 25 - вырезаем 25 записей и отправляем запрос, затем работаем работаем с остатком - рекурсия

        if walls.length < 25
            $timeout(()->
                RestModel.getLikesExecute($scope.userId, walls, $scope.params, "post").then(
                    (likes)->
                        $scope.userWalls.push(walls);
                        $scope.userLikes.push(likes.response);
                        $scope.isSearchLikes(checkedUser, userFriends, $scope.userWalls, $scope.userLikes);
                    (error)->
                        console.log(error);
                )
            ,300)

        else
            tempWalls = walls.splice(0, 24);
            $timeout(()->
                RestModel.getLikesExecute($scope.userId, tempWalls, $scope.params, "post").then(
                    (likes)->
                        $scope.userWalls.push(tempWalls);
                        $scope.userLikes.push(likes.response);
                        $scope.getLikesFromsWalls(checkedUser, userFriends, walls);
                    (error)->
                        console.log(error);
                )
            ,300)

    $scope.isSearchLikes = (checkedUser, userFriends, userWalls, userLikes) ->
        # итоговый массив - обрабатываемый пользователь,фотографии с лайками кол-во фото
        $scope.isLikes.push({user:checkedUser, walls:[], wallsCount:''});

        angular.forEach(userLikes, (likes)->
            angular.forEach(likes, (like, key)->
                wallId = parseInt(key.replace(/\D+/g,""));
                angular.forEach(like.users, (user)->
                    if user == parseInt($scope.userId)
                        if userWalls
                            $scope.addWallWithLike(checkedUser, wallId, userWalls);
                )
            )
        )

        if $scope.isLikes.length > 0 then $scope.result = true;
        $scope.count = $scope.count + 1;

        if userFriends.length != 0 && !$scope.stopped then $scope.searchWallAmongUsers(userFriends) else Loader.stopLoad();


    # выбираем фотки с нужным нам лайком
    $scope.addWallWithLike = (checkedUser, wallId, userWalls) ->
        count = 0;
        angular.forEach(userWalls, (walls)->
            count = count + walls.length;
            angular.forEach(walls, (wall)->
                if wall.id == wallId
                    wall.date = moment.unix(wall.date).format('DD.MM.YYYY HH:mm');
                    $scope.isLikes[$scope.count].walls.push(wall);
            )
        )

        $scope.isLikes[$scope.count].wallsCount = count;

    # остановить сканирование
    $scope.stopScanWall = () ->
        $scope.stopped = true;

    $scope.lookLikesWalls = (walls) ->
        # сохраняем положение скролла
        $scope.offcet = window.pageYOffset;

        $scope.lookWalls = walls;
        console.log(walls);
        $scope.lookedItems = true;



