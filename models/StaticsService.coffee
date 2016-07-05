###
#StaticsService#
Сервис статистики
###

'use strict';

MainModule.service 'Static', ($timeout, $q, RestModel,Loader) ->
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
                            console.log(error);
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
                else
                    console.log('dct');


        sortableFriends: (a,b) ->
            return b.counters.friends - a.counters.friends;



        getPhotoProfileFriends: (friends, date) ->
            if friends.length > 25
                tempFriends = friends.splice(0,25);
                $timeout(()=>
                    RestModel.getProfilePhoto(tempFriends, @params).then(
                        (data)=>
                            angular.forEach(data.response, (item, index)=>
                                if item[0] && item[0].created
                                    if item[0].created > date
                                        angular.forEach(tempFriends, (friend)->
                                            if item[0].owner_id == friend.id
                                                item[0].first_name = friend.first_name
                                                item[0].last_name = friend.last_name
                                        )
                                        @resultUserProfilePhoto.push(data.response[index]);
                            )
                            @getPhotoProfileFriends(friends, date);
                        (error)->
                            console.log(error);
                    )
                ,330)
            else
                if friends.length != 0
                    $timeout(()=>
                        RestModel.getProfilePhoto(friends, @params).then(
                            (data)=>
                                angular.forEach(data.response, (item, index)=>
                                    if item[0] && item[0].created
                                        if item[0].created > date
                                            angular.forEach(friends, (friend)->
                                                console.log(friend);
                                                if item[0].owner_id == friend.id
                                                    item[0].first_name = friend.first_name
                                                    item[0].last_name = friend.last_name
                                            )
                                            @resultUserProfilePhoto.push(data.response[index]);
                                )

#                                console.log('итог', @resultUserProfilePhoto);

                                test = angular.copy(@resultUserProfilePhoto)
                                @resultUserProfilePhoto = [];
                                return test;
                        )
                    ,330)
                else
                    console.log('dct');

    new Static();


