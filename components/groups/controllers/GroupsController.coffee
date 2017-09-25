#GroupsController#

'use strict';

GroupsUserModule.controller 'GroupsController', ($scope, $stateParams, $state, $timeout, $location, Loader, RestModel, Notification, LocalStorage, params, groups) ->

    $scope.window = window;
    $scope.params = params;
    $scope.stateParams = $stateParams;
    $scope.loading = false;
    $scope.page = 1;
    $scope.pageSize = 4;

    $scope.offset = 0;



    $scope.topList = [
        {id:0, name:'Топ лист по лайкам'},
        {id:1, name:'Топ лист по репостам'},
        {id:2, name:'Топ лист по просмотрам'}
    ];
    $scope.selectedTopList = {list:{id:0,name:'Топ лист по лайкам'}};


    $scope.otherGroup = {};
    $scope.tops = [];


    $scope.groups = groups.response.items;


    $scope.returnListFriends = () ->
        $state.transitionTo('friends');

    $scope.getMoreinfo = (group) ->
        $state.transitionTo('groupContent', {groupId:group.id});


    # получить информацию о группе
    $scope.searchGroup = () ->
        if $scope.otherGroup.id
            RestModel.getGroupById($scope.otherGroup.id, $scope.params).then((data)->

                $scope.groups = data.response;
                $scope.tops = [];
            )


    # запускаем поиск лучших постов по лайкам в группе
    $scope.searchTopWall = () ->
        $scope.tops = [];
        if $scope.otherGroup.id
            RestModel.getWallPost($scope.otherGroup.id, $scope.params, 1, true).then((data)->
                if data.error
                    Notification.error('Закрыт доступ к стене, выберите другую группу');
                else
                    $scope.countWalls = data.response.count;
                    $scope.loading = true;
                    count = angular.copy($scope.countWalls);
                    $scope.getPosts(count);

                    $scope.posts = [];
            )


    $scope.searchFivePostToWeek = () ->
        $scope.tops = [];
        if $scope.otherGroup.id
            RestModel.getWallPost($scope.otherGroup.id, $scope.params, 100, true).then((data)->
                if data.error
                    Notification.error('Закрыт доступ к стене, выберите другую группу');
                else
                    $scope.loading = true;
                    $scope.endPosts = false;

                    today = new Date();
                    inWeek = new Date();
                    inWeek.setDate(today.getDate() - 7);
                    inWeek = moment(inWeek).format('x');

                    $scope.posts = [];

                    angular.forEach(data.response.items, (item, index)->
                        if moment.unix(item.date) > moment(parseInt(inWeek)) && index != 0
                            $scope.posts.push(item);
                            $scope.endPosts = false;
                        else
                            $scope.endPosts = true;

                    );


                    if !$scope.endPosts
                        # так как вртли за неделю будет больше 2500 постов, ограничимся одним запросом
                        RestModel.getAllWallPostExecute($scope.otherGroup.id, $scope.params, 2500, 100).then(
                            (data) ->
                                angular.forEach(data, (item)->
                                    if moment.unix(item.date) > moment(parseInt(inWeek))
                                        $scope.posts.push(item);
                                );

                                $scope.loading = false;
                                $scope.countWalls = $scope.posts.length;
                                $scope.procent = 100;
                                $scope.topLikes($scope.posts, 5);

                        )
                    else
                        $scope.loading = false;
                        $scope.countWalls = $scope.posts.length;
                        $scope.procent = 100;
                        $scope.topLikes($scope.posts, 5);
            )


    $scope.getPosts = (count) ->
        $scope.procent = 100 - Math.floor(count * 100 / $scope.countWalls);
        Loader.process($scope.procent);

        if count < 2500
            $timeout(()->
                RestModel.getAllWallPostExecute($scope.otherGroup.id, $scope.params, count, $scope.offset).then(
                    (response)->
                        $scope.offset = 0;
                        $scope.topPostsArray(response, true);
                        $scope.loading = false;
                        $scope.procent = 100;
                    (error) ->
                        $scope.loading = false;
                        Notification.error('Произошла ошибка ' + error.error_msg + '. Попробуйте еще раз');
                )
            ,355)
        else
            $timeout(()->
                RestModel.getAllWallPostExecute($scope.otherGroup.id, $scope.params, count, $scope.offset).then(
                    (response)->
                        $scope.offset = $scope.offset + 2500;
                        count = count - 2500;
                        $scope.topPostsArray(response);
                        $scope.getPosts(count);
                    (error) ->
                        $scope.loading = false;
                        Notification.error('Произошла ошибка ' + error.error_msg + '. Попробуйте еще раз');
                )
            ,355)


    $scope.topPostsArray = (items, end = null) ->
        angular.forEach(items, (item)->
            $scope.posts.push(item);
        )


        if end
            $scope.topLikes($scope.posts, 10);


    $scope.getTransformPost = (posts) ->
        angular.forEach(posts, (post)->
            post.date = moment.unix(post.date).format('DD.MM.YYYY HH:mm');
            post.url = 'https://vk.com//wall-' + $scope.otherGroup.id + '?own=1&w=wall-' + $scope.otherGroup.id + '_' + post.id;
        )

    # топ по лайкам
    $scope.topLikes = (items, count) ->
        $scope.tops = [];
        $scope.tops = angular.copy(items);
        angular.forEach($scope.tops, (item, index)->
            if item.likes.count == 0
                $scope.tops.splice(index,1);
        )
        $scope.tops.sort(RestModel.sortByLikes);

        $scope.tops = $scope.tops.splice(0, count);
        $scope.countBest = if $scope.tops.length < 5 then $scope.tops.length else count;
        $scope.getTransformPost($scope.tops);

    #todo: временно выпилил, не используется
    # топ по репостам
    $scope.topReposts = (items) ->
        $scope.tops = [];
        $scope.tops = angular.copy(items);

        angular.forEach($scope.tops, (item, index)->
            if item.reposts.count == 0
                $scope.tops.splice(index,1);
        )

        items.sort(RestModel.sortByReposts);
        $scope.tops = $scope.tops.splice(0, 10);
        $scope.getTransformPost($scope.tops);


    #todo: временно выпилил, не используется
    # топ по просмотрам
    $scope.topViews = (items) ->
        $scope.tops = [];
        $scope.tops = angular.copy(items);

        angular.forEach($scope.tops, (item, index)->
            if item.views
                if item.views.count == 0
                    $scope.tops.splice(index,1);
            else
                $scope.tops.splice(index,1);
        )

        items.sort(RestModel.sortByViews);
        $scope.tops = $scope.tops.splice(0, 10);


        $scope.getTransformPost($scope.tops);



    #todo: временно выпилил, не используется
    $scope.changeTopList = () ->
        if $scope.selectedTopList.list.id == 0
            $scope.topLikes($scope.posts, 10);
        else if $scope.selectedTopList.list.id == 1
            $scope.topReposts($scope.posts);
        else if $scope.selectedTopList.list.id == 2
            $scope.topViews($scope.posts);








