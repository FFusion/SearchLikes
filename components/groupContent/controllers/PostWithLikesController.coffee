#PostWithLikesController#

'use strict';

GroupContentModule.controller 'PostWithLikesController', ($scope, $stateParams, $state, $timeout, Loader, RestModel, Notification, LocalStorage, params) ->

    $scope.loading = true;
    $scope.params = params;
    $scope.postsWithLikes = [];
    $scope.arrayLikes = [];
    $scope.countPost = 0;
    $scope.empty = false;
    Loader.startLoad();
    RestModel.getWallPost($stateParams.groupId, $scope.params, 100, 'all').then(
        (data)->
            response = data.response;
            if response.count > 0
                angular.forEach(response.items, (item)->
                    if item.likes.count > 0 then $scope.postsWithLikes.push(item);
                )
                $scope.workingWithPost($scope.postsWithLikes);
            else
                $scope.empty = true;
        (error)->
            Notification.error(error);
    )




    $scope.workingWithPost = (posts) ->
        if posts.length != 0
            post = posts.splice(0,1);
            $scope.countPost++;

            Loader.process($scope.countPost);
            $scope.getScanUserWall(post, posts);
        else
            $scope.getScanUserWall(post, posts);


    $scope.getScanUserWall = (post, posts, count = null) ->
        if post == undefined
            $scope.workWithLikes($scope.arrayLikes);
        else

            if count is null then $scope.offset = 0;

            if count < 1000 || count is null
                $timeout(()->
                    RestModel.getAllLikes('-' + $stateParams.groupId, $scope.params, post[0].id, 'post', count || 1000, $scope.offset).then(
                        (data)->
                            if count is null then count = data.response.count;
                            if angular.isDefined($scope.arrayLikes[$scope.arrayLikes.length - 1]) && post[0].id == $scope.arrayLikes[$scope.arrayLikes.length - 1].post[0].id
                                $scope.arrayLikes[$scope.arrayLikes.length - 1].likes.push(data.response.items);
                            else
                                $scope.arrayLikes.push({likes:data.response.items, post:post});

                            if count < 1000
                                $scope.workingWithPost(posts);
                            else
                                count = count - 1000;
                                $scope.offset = $scope.offset + 1000;
                                $scope.getScanUserWall(post, posts, count);
                        (error)->
                            $scope.getScanUserWall(post, posts, count);
                    );
                ,335)

            else
                $timeout(()->
                    RestModel.getAllLikes('-' + $stateParams.groupId, $scope.params, post[0].id, 'post', count || 1000, $scope.offset).then(
                        (data)->
                            if angular.isDefined($scope.arrayLikes[$scope.arrayLikes.length - 1]) && post[0].id == $scope.arrayLikes[$scope.arrayLikes.length - 1].post[0].id
                                $scope.arrayLikes[$scope.arrayLikes.length - 1].likes.push(data.response.items);
                            else
                                $scope.arrayLikes.push({likes:data.response.items, post:post});
                            count = count - 1000;
                            $scope.offset = $scope.offset + 1000;
                            $scope.getScanUserWall(post, posts, count);
                        (error)->
                            $scope.getScanUserWall(post, posts, count);
                    )
                ,335)


    $scope.workWithLikes = (likes) ->
        Loader.stopLoad();
        $scope.wallWithLikes = [];
        angular.forEach(likes, (items)->
            angular.forEach(items.likes, (item)->
                if parseInt($stateParams.userId) == item
                    items.post[0].date = moment.unix(items.post[0].date).format('DD.MM.YYYY HH:mm');
                    $scope.wallWithLikes.push(items.post[0])
            )
        )
        $scope.loading = false;


    $scope.returnWithGroup = () ->
        $state.transitionTo('groupContent', {groupId:$stateParams.groupId});

    $scope.main = () ->
        $state.transitionTo('friends');