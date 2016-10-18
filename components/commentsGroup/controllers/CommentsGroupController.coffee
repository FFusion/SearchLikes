#CommentsGroupController#

'use strict';
CommentsGroupModule.controller 'CommentsGroupController', ($scope, params, $stateParams, $timeout, RestModel, Notification, Loader, currentUser) ->

    # параметры
    $scope.params = params;

    # для комментарий
    $scope.count = 0;
    $scope.window = window;
    $scope.group = {};

    # тип (топик или запись на стене)
    $scope.type = {};
    # по умолчанию пост
    $scope.type.searchType = "post";

    # итоговый массив комментариев
    $scope.commentsOfUser = [];

    # процент загрузки
    $scope.procent = 0;

    # выбранный пользователь - id
    $scope.currentUserId = $stateParams.userId;
    # выбранный пользователь - объект
    $scope.currentUser = currentUser.response[0];

    # отображение после анализа группы
    $scope.isAnalisys = false;


    # todo:пока не использую, дальше видно будет
    $scope.loading = false;
    $scope.result = false;
    $scope.stopped = false;
    $scope.lookedItems = false;
    $scope.onlyCurrent = true;



    # назад - к предыдущему экрану
    $scope.back = () ->
        $scope.stopped = true;
        if Loader.ID isnt null
            Loader.stopLoad();
        $scope.window.history.back();



    $scope.allFriends = angular.copy($scope.userFriends);

    # анализируем группу
    # интересует: название, кол-во топиков, кол-во записей на стене, комменты на первых 5 записях,
    # тип группы (работаем далее только с открытой)
    $scope.analysisGroup = () ->
        $scope.isAnalisys = false;

        $scope.group.closed = false;

        # получаем группу по id
        RestModel.getGroupById($scope.group.id, $scope.params).then(
            (data)->

                # имя группы
                $scope.group.name = data.response[0].name;

                # если есть топики - кол-во
                if angular.isDefined(data.response[0].counters)
                    $scope.group.topicsCount = data.response[0].counters.topics;
                else
                    $scope.group.topicsCount = 0;

                # статус (закрытая - открытая)
                if data.response[0].is_closed == 0
                    # получаем 5 записей на стене для оценки кол-ва комментарий.
                    RestModel.getAllWallPost($scope.group.id, $scope.params, 5, 0, true).then(
                        (data)->
                            # кол-во записей на стене группы
                            $scope.group.countItems = data.response.count;

                            # кол-во комментов первых 5 записей группы
                            $scope.group.countComments = 0;
                            angular.forEach(data.response.items, (item)->
                                $scope.group.countComments += item.comments.count;
                            )

                            $scope.isAnalisys = true;
                        (error) ->
                            Notification.error(error);
                    )
                else
                    $scope.group.closed = true;
            (error)->
                Notification.error(error);
        )



    $scope.getComments = () ->
        Loader.startLoad();

        $scope.isResultComments = [];

        $scope.result = true;
        $scope.stopped = false;

        $scope.procent = 0;
        $scope.count = 0;
        $scope.groupWall = [];
        $scope.offset = 0;
        $scope.commentsOfUser = [];

        $scope.scanGroupComments();

    $scope.scanGroupComments = (count = null) ->
        if count is null then $scope.offset = 0;

        if count is null then count = $scope.group.searchItems;
        # получаем записи со стены (максимум 100)
        if count < 100 || count is null
            $timeout(()->
                RestModel.getAllWallPost($scope.group.id, $scope.params, count || 100, $scope.offset, true).then(
                    (data)->

                        # собираем все записи в groupWall
                        $scope.groupWall.push(data.response.items);

                        if count <= 100
                            $scope.filteredPosts($scope.groupWall);
                        else
                            count = count - 100;
                            $scope.offset = $scope.offset + 100;
                            $scope.scanGroupComments(count);
                    (error)-> Notification.error(error);
                );
            ,345)

        else
            $timeout(()->
                RestModel.getAllWallPost($scope.group.id,$scope.params, 100,$scope.offset).then(
                    (data)->
                        $scope.groupWall.push(data.response.items);
                        count = count - 100;
                        $scope.offset = $scope.offset + 100;
                        $scope.scanGroupComments(count);
                    (error)->
                        Notification.error(error);
                )
            ,345)

    # фильтруем записи с комментами после окончания сканирования стены
    $scope.filteredPosts = (postsArray) ->

        postsWithComment = [];
        angular.forEach(postsArray, (posts)->
            angular.forEach(posts, (post)->
                if post.comments.count > 0
                    postsWithComment.push(post);
            )
        )

        $scope.allPosts = postsWithComment.length;


        console.log('posts',postsWithComment);
        $scope.getCommentsForPost(postsWithComment[0], postsWithComment);

    # получаем комменты у каждой записи (макс 100)
    $scope.getCommentsForPost = (post, posts, count = null) ->

        $scope.procent = 100 - Math.floor(posts.length * 100 / $scope.allPosts);
        Loader.process($scope.procent);

        if count is null
            $scope.offset = 0;
            count = post.comments.count;

        if !$scope.stopped
            if count < 100
               $timeout(()->
                   RestModel.getCommentsWall(post.owner_id, post.id, $scope.params, count || 100, $scope.offset).then(
                       (data)->
                           if !data.error
                               if count is null then count = data.response.count;
                                # ищем выбранного чувака в комментах
                               $scope.searchCurrentUser(post, data.response.items);
                               if count < 100
                                   posts.splice(0, 1);

                                   if posts.length > 0
                                       $scope.getCommentsForPost(posts[0], posts);
                                   else
                                       # тут глушим загрузку
                                       $scope.procent = 100 - Math.floor(posts.length * 100 / $scope.allPosts);
                                       Loader.stopLoad();
                               else
                                   count = count - 100;
                                   $scope.offset = $scope.offset + 100;
                                   if posts.length > 0
                                       $scope.getCommentsForPost(posts[0], posts, count);
                                   else
                                       # тут глушим загрузку
                                       $scope.procent = 100 - Math.floor(posts.length * 100 / $scope.allPosts);
                                       Loader.stopLoad();

                           else
                               Notification.error('Произошла ошибка ' + data.error.error_msg);
                               posts.splice(0, 1);
                               if posts.length > 0
                                   $scope.getCommentsForPost(posts[0], posts);

                       (error)->
                           Notification.error('Произошла ошибка ' + error.error_msg);
                           posts.splice(0, 1);
                           if posts.length > 0
                               $scope.getCommentsForPost(posts[0], posts);
                   )
               ,345)
            else
                $timeout(()->
                    RestModel.getCommentsWall(post.owner_id, post.id, $scope.params, count || 100, $scope.offset).then(
                        (data)->
                            if !data.error
                                if count is null then count = data.response.count;
                                $scope.searchCurrentUser(post, data.response.items);
                                if count > 100
                                    count = count - 100;
                                    $scope.offset = $scope.offset + 100;
                                else
                                    $scope.getCommentsForPost(posts[0], posts);

                                if posts.length > 0
                                    $scope.getCommentsForPost(posts[0], posts, count);

                            else
                                Notification.error('Произошла ошибка ' + data.error.error_msg);
                                posts.splice(0, 1);
                                if posts.length > 0
                                    $scope.getCommentsForPost(posts[0], posts);

                        (error)->
                            Notification.error('Произошла ошибка ' + error.error_msg);
                            posts.splice(0, 1);
                            if posts.length > 0
                                $scope.getCommentsForPost(posts[0], posts);
                    )
                ,345)


    # ищем среди комментов нужного чувака
    $scope.searchCurrentUser = (post, comments) ->
        resultComments = [];

        # пробегаемся по комментам
        angular.forEach(comments, (comment)->
            if parseFloat(comment.from_id) == parseFloat($scope.currentUserId)
                comment.date = moment.unix(comment.date).format('DD.MM.YYYY HH:mm');
                resultComments.push(comment);
        )


        if resultComments.length > 0
            # итоговой массив - пост + коммент
            $scope.commentsOfUser.push({comments:resultComments, post:post});


    # остановить сканирование
    $scope.stopScan = () ->
        $scope.stopped = true;

