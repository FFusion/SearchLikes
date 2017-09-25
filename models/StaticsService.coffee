###
#StaticsService#
Сервис статистики
###

'use strict';

MainModule.service 'Static', ($timeout, $q, RestModel, Loader, Notification) ->
    class Static

        resultFriends: [],
        resultUserProfilePhoto: [];
        params:null

        # статистика по кол-ву друзей
        getListCountFriends: (friends) ->
            if friends.length > 25
                tempFriendsArray = friends.splice(0,25);
                $timeout(()=>
                    RestModel.getAllCountFriends(tempFriendsArray, @params).then(
                        (data)=>
                            angular.forEach(data.response, (user)=>
                                @resultFriends.push(user[0]);
                            )
                            @getListCountFriends(friends);
                        (error)->
                            Notification.error(error);
                    )
                ,330)
            else
                if friends.length != 0
                    $timeout(()=>
                        RestModel.getAllCountFriends(friends, @params).then(
                            (data)=>
                                angular.forEach(data.response, (user)=>
                                    @resultFriends.push(user[0]);
                                )

                                @resultFriends = @resultFriends.sort(@sortableFriends);
                                @resultFriends = Loader.renderBand(@resultFriends);

                                return @resultFriends;
                        )
                    ,330)



        sortableFriends: (a,b) ->
            return b.counters.friends - a.counters.friends;



        getPhotoProfileFriends: (friends, date) ->
            if friends.length > 25
                tempFriends = friends.splice(0,25);
                $timeout(()=>
                    RestModel.getProfilePhoto(tempFriends, @params).then(
                        (data)=>
                            angular.forEach(data.response, (item, index)=>
                                if item.items[0] && item.items[0].date
                                    if item.items[0].date > date
                                        angular.forEach(tempFriends, (friend)->
                                            if item.items[0].owner_id == friend.id
                                                item.items[0].first_name = friend.first_name
                                                item.items[0].last_name = friend.last_name
                                        )
                                        @resultUserProfilePhoto.push(data.response[index].items);
                            )
                            @getPhotoProfileFriends(friends, date);
                        (error)->
                            Notification.error(error);
                    )
                ,330)
            else
                if friends.length != 0
                    $timeout(()=>
                        RestModel.getProfilePhoto(friends, @params).then(
                            (data)=>
                                angular.forEach(data.response, (item, index)=>
                                    if item.items[0] && item.items[0].created
                                        if item.items[0].created > date
                                            angular.forEach(friends, (friend)->
                                                if item.items[0].owner_id == friend.id
                                                    item.items[0].first_name = friend.first_name
                                                    item.items[0].last_name = friend.last_name
                                            )
                                            @resultUserProfilePhoto.push(data.response[index].items);
                                )


                                test = angular.copy(@resultUserProfilePhoto)
                                @resultUserProfilePhoto = [];
                                return test;
                        )
                    ,330)


        # метод получения чуваков, которые скрыли выбранного пользователя
        getHideFriendsList: (count, array, userId, result) ->
            localUsers = [];
            if count < 25
                $timeout(()=>
                    RestModel.getFriendsExecute(array, @params, userId).then(
                        (response)->
                            angular.forEach(response, (user)->
                                if user.hide then result.push(user);
                            )

                            return result;
                        (error) ->
                            Notification.error('Произошла ошибка, обновите страницу ' + error.error_msg);
                    )
                ,350)
            else
                localUsers = array.splice(0,25);
                $timeout(()=>
                    RestModel.getFriendsExecute(localUsers, @params, userId).then(
                        (response)=>
                            angular.forEach(response, (user)->
                                if user.hide then result.push(user);
                            )
                            count = count - 25;
                            @getHideFriendsList(count, array, userId, result);
                        (error)->
                            Notification.error('Произошла ошибка, обновите страницу ' + error.error_msg);

                    )
                ,350)


        # просто получаем информацию по массиву id пользователей
        getFriends: (array, result) ->
            user = array.splice(0,1);


            $timeout(()=>
                RestModel.moreInfo(parseInt(user[0].id), @params).then(
                    (data) =>
                        result.push(data.response[0]);
                        if array.length != 0
                            @getFriends(array, result);
                        else
                            return result;
                    (error) ->
                        Notification.error('Произошла ошибка ' + error.error_msg);
                        return error;
                );
            ,330)


        filterFriendsListForFamilyStatus: (friends) ->
            listFriends = angular.copy(friends);

            notStatusArray = [];
            notMarriedArray = [];
            meetingArray = []
            engagedArray = [];
            marriedArray = [];
            complicatedArray = [];
            activeArray = [];
            lovedArray = [];
            hideStatusArray = [];

            angular.forEach(listFriends, (friend)->
                if friend.relation == 1
                    notMarriedArray.push(friend);
                else if friend.relation == 2
                    meetingArray.push(friend);
                else if friend.relation == 3
                    engagedArray.push(friend);
                else if friend.relation == 4
                    marriedArray.push(friend);
                else if friend.relation == 5
                    complicatedArray.push(friend);
                else if friend.relation == 6
                    activeArray.push(friend);
                else if friend.relation == 7
                    lovedArray.push(friend);
                else
                    if friend.relation == 0
                        notStatusArray.push(friend);
                    else
                        hideStatusArray.push(friend);
            )


            [
                notStatusArray,
                notMarriedArray,
                meetingArray,
                engagedArray,
                marriedArray,
                complicatedArray,
                activeArray,
                lovedArray,
                hideStatusArray
            ];

        filterFriendsListForParams: (friends, params) ->
            listFriends = angular.copy(friends);

            yesParamsArray = [];
            notParamsArray = [];

            angular.forEach(listFriends, (friend)->
                if Array.isArray(friend[params])
                    if friend[params].length > 0
                        yesParamsArray.push(friend);
                    else
                        notParamsArray.push(friend);
                else

                    if friend[params] == 1
                        yesParamsArray.push(friend);
                    else
                        notParamsArray.push(friend);
            )

            [
                yesParamsArray,
                notParamsArray
            ];


    new Static();


