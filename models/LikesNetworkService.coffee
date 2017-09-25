###
#LikesNetworkService#
Сервис определения лайков на фотках у друзей друзей
Сканируем Сетку друзей
###

'use strict';

MainModule.service 'LikesNetwork', ($timeout, $q, RestModel, Loader, Notification) ->

    network: []
    params:null


    # метод получения чуваков, которые в друзьях у ваших друзей
    getFriendsNetworkList: (count, array, result = null) ->
        localUsers = [];
        if count < 25
            $timeout(()=>
                RestModel.getNetworkFriendsExecute(array, @params).then(
                    (response)=>
                        @checkSameUsers(response.data.response);
                        @network = @array_unique(@network);
                        return @network;

                    (error) ->
                        Notification.error('Произошла ошибка, обновите страницу ' + error.error_msg);
                )
            ,350)
        else
            localUsers = array.splice(0,25);
            $timeout(()=>
                RestModel.getNetworkFriendsExecute(localUsers, @params).then(
                    (response)=>
                        count = count - 25;
                        @checkSameUsers(response.data.response);
                        @getFriendsNetworkList(count, array, result);
                    (error)->
                        Notification.error('Произошла ошибка, обновите страницу ' + error.error_msg);

                )
            ,350)

    checkSameUsers: (users) ->
        angular.forEach(users, (user)=>
           @network = @network.concat(user.items);
        )



    array_unique: (inArr) ->
        uniHash = {}
        outArr = []
        i = inArr.length
        while i--
            uniHash[inArr[i].id] = inArr[i];
        for i of uniHash
            outArr.push(uniHash[i]);
        outArr;



